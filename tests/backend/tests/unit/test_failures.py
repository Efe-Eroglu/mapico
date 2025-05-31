"""
Bu modül, test gösterge panosunda hataların nasıl görüntülendiğini göstermek için özellikle başarısız olan testler içerir.
"""
import pytest

def test_intentional_failure():
    """Bu test, gösterge panosunda başarısız test görünümünü göstermek için kasıtlı olarak başarısız olur."""
    assert False, "Bu test kasıtlı olarak başarısız oldu"

def test_expected_vs_actual():
    """Beklenen ve gerçek değerlerin karşılaştırılmasını gösteren başarısız test."""
    expected = "beklenen değer"
    actual = "gerçek değer"
    assert expected == actual, f"Beklenen: {expected}, Gerçek: {actual}"

def test_exception_raised():
    """Beklenmeyen bir istisnanın fırlatıldığı başarısız test."""
    def function_that_raises():
        raise ValueError("Bu bir hata mesajıdır")
    
    function_that_raises()

@pytest.mark.skip(reason="Bu test atlandı")
def test_skipped():
    """Bu test atlanacak ve raporlarda ayrı bir kategori olarak gösterilecek."""
    assert True 