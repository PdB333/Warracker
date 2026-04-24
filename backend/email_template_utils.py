from pathlib import Path
from typing import Dict, Iterable, Optional, Tuple
import logging

EMAIL_TEMPLATE_DIR = Path(__file__).resolve().parent / 'email_templates'
DEFAULT_EMAIL_LANGUAGE = 'en'


def _normalize_language(language: Optional[str]) -> str:
    if not language:
        return DEFAULT_EMAIL_LANGUAGE
    return str(language).strip().replace('-', '_')


def get_language_candidates(language: Optional[str]) -> Iterable[str]:
    normalized = _normalize_language(language)
    candidates = []
    if normalized:
        candidates.append(normalized)
        if '_' in normalized:
            base_lang = normalized.split('_', 1)[0]
            if base_lang and base_lang not in candidates:
                candidates.append(base_lang)
    if DEFAULT_EMAIL_LANGUAGE not in candidates:
        candidates.append(DEFAULT_EMAIL_LANGUAGE)
    return candidates


def load_localized_template(
    template_name: str,
    language: Optional[str],
    fallback_value: str,
    logger: Optional[logging.Logger] = None
) -> str:
    for candidate in get_language_candidates(language):
        template_path = EMAIL_TEMPLATE_DIR / candidate / template_name
        try:
            if template_path.exists():
                return template_path.read_text(encoding='utf-8')
        except Exception as e:
            if logger:
                logger.warning(f"Failed reading email template {template_path}: {e}")

    # Backward-compatible flat fallback location (legacy templates)
    legacy_path = EMAIL_TEMPLATE_DIR / template_name
    try:
        if legacy_path.exists():
            return legacy_path.read_text(encoding='utf-8')
    except Exception as e:
        if logger:
            logger.warning(f"Failed reading legacy email template {legacy_path}: {e}")

    if logger:
        logger.warning(f"Email template not found for '{template_name}' and language '{language}'. Using fallback.")
    return fallback_value


def render_localized_email(
    language: Optional[str],
    context: Dict[str, object],
    subject_template_name: str,
    text_template_name: str,
    html_template_name: str,
    default_subject: str,
    default_text: str,
    default_html: str,
    logger: Optional[logging.Logger] = None
) -> Tuple[str, str, str]:
    subject_template = load_localized_template(subject_template_name, language, default_subject, logger=logger)
    text_template = load_localized_template(text_template_name, language, default_text, logger=logger)
    html_template = load_localized_template(html_template_name, language, default_html, logger=logger)

    try:
        subject = subject_template.format(**context).strip()
        text_body = text_template.format(**context)
        html_body = html_template.format(**context)
    except KeyError as e:
        if logger:
            logger.error(f"Email template variable missing: {e}. Falling back to defaults.")
        subject = default_subject
        text_body = default_text.format(**context)
        html_body = default_html.format(**context)

    return subject, text_body, html_body
