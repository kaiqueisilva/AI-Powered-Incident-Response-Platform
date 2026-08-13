import json
import os
import time
import boto3
import urllib.request

ssm = boto3.client("ssm")
logs_client = boto3.client("logs")
sns = boto3.client("sns")

LOG_GROUP = "/ecs/air-app"
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def get_api_key():
    """Busca a API key do Gemini guardada no SSM (nunca em texto puro no código)."""
    response = ssm.get_parameter(
        Name="/air/gemini/api-key", WithDecryption=True
    )
    return response["Parameter"]["Value"]


def get_recent_logs(minutes=10, limit=30):
    """Pega os logs mais recentes da aplicação, pra dar contexto pra IA."""
    end_time = int(time.time() * 1000)
    start_time = end_time - (minutes * 60 * 1000)

    response = logs_client.filter_log_events(
        logGroupName=LOG_GROUP,
        startTime=start_time,
        endTime=end_time,
        limit=limit,
    )
    messages = [event["message"] for event in response.get("events", [])]
    return "\n".join(messages) if messages else "Nenhum log encontrado no período."


def ask_ai(alarm_name, alarm_reason, logs):
    """Manda o contexto do incidente pro Gemini e pede uma análise."""
    api_key = get_api_key()

    prompt = f"""Você é um SRE experiente analisando um alerta de produção.

ALARME: {alarm_name}
MOTIVO: {alarm_reason}

LOGS RECENTES DA APLICAÇÃO:
{logs}

Com base nisso, responda em português, de forma objetiva (máximo 200 palavras):
1. Possível causa raiz
2. Ação recomendada imediata
3. Nível de urgência (baixo/médio/alto)
"""

    body = json.dumps({
        "contents": [{"parts": [{"text": prompt}]}]
    }).encode("utf-8")

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key={api_key}"

    req = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": "application/json"},
    )

    with urllib.request.urlopen(req) as response:
        result = json.loads(response.read())
        return result["candidates"][0]["content"]["parts"][0]["text"]


def handler(event, context):
    # O SNS manda o alarme dentro de um "Record"
    sns_message = json.loads(event["Records"][0]["Sns"]["Message"])

    alarm_name = sns_message.get("AlarmName", "Desconhecido")
    alarm_reason = sns_message.get("NewStateReason", "Sem detalhes")

    logs = get_recent_logs()
    analysis = ask_ai(alarm_name, alarm_reason, logs)

    final_message = f"""🤖 AI TRIAGE - {alarm_name}

{analysis}

---
Motivo original do alarme: {alarm_reason}
"""

    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=f"[AI Triage] {alarm_name}",
        Message=final_message,
    )

    return {"statusCode": 200, "body": "Triage completed"}