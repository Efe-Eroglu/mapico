from fastapi import APIRouter, Depends, status
from app.schemas.encryption import (
    EncryptRequest, EncryptResponse,
    DecryptRequest, DecryptResponse
)
from app.services.encryption import encrypt_text, decrypt_text
from app.services.auth import get_current_user

router = APIRouter(
    prefix="/api/v1/crypto",
    tags=["Encryption"]
)

@router.post(
    "/encrypt",
    response_model=EncryptResponse,
    status_code=status.HTTP_200_OK,
    summary="Encrypt plaintext",
    description="Encrypt a UTF-8 string and return a base64 token"
)
def encrypt_api(
    req: EncryptRequest,
    _: object = Depends(get_current_user)
):
    ct = encrypt_text(req.plaintext)
    return EncryptResponse(ciphertext=ct)


@router.post(
    "/decrypt",
    response_model=DecryptResponse,
    status_code=status.HTTP_200_OK,
    summary="Decrypt ciphertext",
    description="Decrypt a base64 token back to UTF-8 plaintext"
)
def decrypt_api(
    req: DecryptRequest,
    _: object = Depends(get_current_user)
):
    pt = decrypt_text(req.ciphertext)
    return DecryptResponse(plaintext=pt)
