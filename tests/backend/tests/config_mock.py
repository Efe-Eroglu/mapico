"""
Test sırasında kullanılacak mock ayarlar
"""
from dataclasses import dataclass

@dataclass
class MockSettings:
    POSTGRES_USER: str = "test"
    POSTGRES_PASSWORD: str = "test"
    POSTGRES_DB: str = "test_db"
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432
    ENCRYPTION_KEY: str = "cGFzc3dvcmRwYXNzd29yZHBhc3N3b3JkcGFzc3dvcmQ="
    SECRET_KEY: str = "8b5a1c29d765cd04c9e0b07ebfc9d0349a1e9bfc5e6d0fb4f5b894b5a98c0e1d"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    @property
    def DATABASE_URL(self) -> str:
        return "sqlite:///:memory:"

# Mock settings örneği
settings = MockSettings() 