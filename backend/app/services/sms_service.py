import os
import random
import logging

logger = logging.getLogger("audia.sms")

TWILIO_ACCOUNT_SID = os.environ.get("TWILIO_ACCOUNT_SID")
TWILIO_AUTH_TOKEN = os.environ.get("TWILIO_AUTH_TOKEN")
TWILIO_FROM_NUMBER = os.environ.get("TWILIO_FROM_NUMBER")


def _send_via_twilio(to: str, codigo: str) -> bool:
    try:
        from twilio.rest import Client

        client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
        message = client.messages.create(
            body=f"Tu código de verificación de Audia es: {codigo}",
            from_=TWILIO_FROM_NUMBER,
            to=to,
        )
        logger.info(f"Twilio SMS sent: {message.sid}")
        return True
    except Exception as e:
        logger.error(f"Twilio error: {e}")
        return False


def is_configured() -> bool:
    return bool(TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN and TWILIO_FROM_NUMBER)


def send_sms(to: str, codigo: str) -> bool:
    if is_configured():
        return _send_via_twilio(to, codigo)

    logger.info(f"=== SMS SIMULADO: Código para {to} => {codigo} ===")
    return False


def generate_code() -> str:
    return f"{random.randint(0, 9999):04d}"
