import smtplib
import random
import string
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings


def generate_verification_code() -> str:
    return ''.join(random.choices(string.digits, k=6))


async def send_verification_email(to_email: str, name: str, code: str) -> bool:
    if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
        print(f"[DEV] Verification code for {to_email}: {code}")
        return True
    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = f"Master Scan — Tasdiqlash kodi: {code}"
        msg["From"] = settings.EMAIL_FROM
        msg["To"] = to_email
        html = f"""
        <html><body style="font-family:Arial,sans-serif;background:#f8f9fa;padding:32px;">
          <div style="max-width:480px;margin:0 auto;background:#fff;border-radius:16px;padding:32px;">
            <div style="text-align:center;margin-bottom:24px;">
              <div style="background:#1A73E8;display:inline-block;padding:12px 20px;border-radius:12px;">
                <span style="color:#fff;font-size:22px;font-weight:bold;">🔧 Master Scan</span>
              </div>
            </div>
            <h2 style="color:#202124;">Salom, {name}!</h2>
            <p style="color:#5F6368;">Email manzilingizni tasdiqlash uchun quyidagi kodni kiriting. Kod <strong>10 daqiqa</strong> amal qiladi.</p>
            <div style="background:#f1f3f4;border-radius:12px;padding:24px;text-align:center;margin:24px 0;">
              <span style="font-size:40px;font-weight:bold;letter-spacing:12px;color:#1A73E8;">{code}</span>
            </div>
            <p style="color:#5F6368;font-size:13px;">Agar siz ro'yxatdan o'tmagan bo'lsangiz, bu xabarni e'tiborsiz qoldiring.</p>
          </div>
        </body></html>
        """
        msg.attach(MIMEText(html, "html"))
        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10) as server:
            server.ehlo()
            server.starttls()
            server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
            server.sendmail(settings.EMAIL_FROM, to_email, msg.as_string())
        return True
    except Exception as e:
        print(f"[EMAIL ERROR] {to_email}: {e}")
        return False


async def send_store_request_notification(store_data) -> bool:
    if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
        print(f"[DEV] Yangi do'kon so'rovi: {store_data.name}")
        return True
    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = f"Master Scan — Yangi do'kon so'rovi: {store_data.name}"
        msg["From"] = settings.EMAIL_FROM
        msg["To"] = settings.SMTP_USER
        html = f"""
        <html><body style="font-family:Arial,sans-serif;padding:24px;">
          <h2 style="color:#1A73E8;">🔧 Yangi do'kon qo'shish so'rovi</h2>
          <table style="border-collapse:collapse;width:100%;margin-top:16px;">
            <tr style="background:#f8f9fa;"><td style="padding:10px;font-weight:bold;width:40%;">Do'kon nomi</td><td style="padding:10px;">{store_data.name}</td></tr>
            <tr><td style="padding:10px;font-weight:bold;">Turi</td><td style="padding:10px;">{store_data.store_type}</td></tr>
            <tr style="background:#f8f9fa;"><td style="padding:10px;font-weight:bold;">Kategoriya</td><td style="padding:10px;">{store_data.category}</td></tr>
            <tr><td style="padding:10px;font-weight:bold;">Manzil</td><td style="padding:10px;">{store_data.address}</td></tr>
            <tr style="background:#f8f9fa;"><td style="padding:10px;font-weight:bold;">Telefon</td><td style="padding:10px;">{store_data.phone}</td></tr>
            <tr><td style="padding:10px;font-weight:bold;">Ish vaqti</td><td style="padding:10px;">{store_data.working_hours or '-'}</td></tr>
            <tr style="background:#f8f9fa;"><td style="padding:10px;font-weight:bold;">Murojaat qiluvchi</td><td style="padding:10px;">{store_data.applicant_name}</td></tr>
            <tr><td style="padding:10px;font-weight:bold;">Email</td><td style="padding:10px;">{store_data.applicant_email}</td></tr>
          </table>
          <p style="margin-top:20px;color:#666;">Admin paneldan tasdiqlang yoki rad eting.</p>
        </body></html>
        """
        msg.attach(MIMEText(html, "html"))
        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10) as server:
            server.ehlo()
            server.starttls()
            server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
            server.sendmail(settings.EMAIL_FROM, settings.SMTP_USER, msg.as_string())
        return True
    except Exception as e:
        print(f"[EMAIL ERROR] Store notification: {e}")
        return False
