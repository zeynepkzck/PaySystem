DROP TABLE IF EXISTS Fatura, Odeme, Kredi_Karti, Havale_EFT, Odeme_Yontemi, Basvuru, Is_Ilani, Referans, Beceri, CV, Abonelik, Bireysel_Kullanici, Isveren, Abonelik_Plani, Kullanici, Kampanya_Kupon CASCADE;

--Kullanici ana tablosu (supertype)
CREATE TABLE Kullanici (
    Kullanici_ID INT PRIMARY KEY,
    EPosta VARCHAR(100) UNIQUE NOT NULL,
    Sifre VARCHAR(50) NOT NULL,
    Kayit_Tarihi DATE DEFAULT CURRENT_DATE,
    Kullanici_Tipi VARCHAR(20) --"bireysel" ya da "isveren"
);

--Abonelik Planları tablosu 
CREATE TABLE Abonelik_Plani (
    Plan_ID SERIAL PRIMARY KEY,
    Plan_Adi VARCHAR(50) NOT NULL,
    Fiyat DECIMAL(10,2) NOT NULL,
    Sure_Gun INT NOT NULL
);

--Bireysel Kullanici tablosu
CREATE TABLE Bireysel_Kullanici (
    Kullanici_ID INT PRIMARY KEY,
    Ad VARCHAR(50) NOT NULL,
    Soyad VARCHAR(50) NOT NULL,
    Dogum_Tarihi DATE,
    Cinsiyet VARCHAR(10),
    FOREIGN KEY (Kullanici_ID) REFERENCES Kullanici(Kullanici_ID) ON DELETE CASCADE
);

--Isveren tablosu
CREATE TABLE Isveren (
    Kullanici_ID INT PRIMARY KEY,
    Sirket_Adi VARCHAR(100) NOT NULL,
    Sektor VARCHAR(50),
    Web_Sitesi VARCHAR(100),
    Sirket_Adresi TEXT,
    FOREIGN KEY (Kullanici_ID) REFERENCES Kullanici(Kullanici_ID) ON DELETE CASCADE
);

--Abonelikleri tutan tablo
CREATE TABLE Abonelik(
    Abonelik_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT NOT NULL,
    Plan_ID INT NOT NULL,
    Baslangic_Tarihi DATE DEFAULT CURRENT_DATE,
    Durum VARCHAR(20) DEFAULT 'Aktif',
    FOREIGN KEY (Kullanici_ID) REFERENCES Kullanici(Kullanici_ID) ON DELETE CASCADE,
    FOREIGN KEY (Plan_ID) REFERENCES Abonelik_Plani(Plan_ID)
);

--Odeme Yontemi Supertype
CREATE TABLE Odeme_Yontemi(
    Yontem_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT NOT NULL,
    Yontem_Tipi VARCHAR(50), 
    FOREIGN KEY (Kullanici_ID) REFERENCES Kullanici(Kullanici_ID) ON DELETE CASCADE
);

--Kredi karti detay subtype
CREATE TABLE Kredi_Karti (
    Yontem_ID INT PRIMARY KEY,
    Kart_No VARCHAR(16) NOT NULL,
    Son_Kullanma VARCHAR(5) NOT NULL,
    CVV VARCHAR(3) NOT NULL,
    FOREIGN KEY (Yontem_ID) REFERENCES Odeme_Yontemi(Yontem_ID) ON DELETE CASCADE
);

--eft/havale subtype
CREATE TABLE Havale_EFT (
    Yontem_ID INT PRIMARY KEY,
    IBAN VARCHAR(34) NOT NULL,
    Banka_Adi VARCHAR(50) NOT NULL,
    FOREIGN KEY (Yontem_ID) REFERENCES Odeme_Yontemi(Yontem_ID) ON DELETE CASCADE
);

--odeme işlemleri
CREATE TABLE Odeme (
    Odeme_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT NOT NULL,
    Yontem_ID INT NOT NULL,
    Tutar DECIMAL(10,2) NOT NULL,
    Para_Birimi VARCHAR(3) DEFAULT 'TRY',
    Odeme_Tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Durum VARCHAR(20) CHECK (Durum IN ('Başarılı', 'Beklemede', 'İptal')),
    FOREIGN KEY (Kullanici_ID) REFERENCES Kullanici(Kullanici_ID),
    FOREIGN KEY (Yontem_ID) REFERENCES Odeme_Yontemi(Yontem_ID) ON DELETE CASCADE
);

--Fatura tablosu
CREATE TABLE Fatura (
    Fatura_ID SERIAL PRIMARY KEY,
    Odeme_ID INT UNIQUE NOT NULL,
    Fatura_No VARCHAR(50) UNIQUE NOT NULL,
    Kesim_Tarihi DATE DEFAULT CURRENT_DATE,
    Vergi_No VARCHAR(20),
    FOREIGN KEY (Odeme_ID) REFERENCES Odeme(Odeme_ID) ON DELETE CASCADE
);

CREATE TABLE CV (
    CV_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT NOT NULL,
    Baslik VARCHAR(100),
    Olusturma_Tarihi DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (Kullanici_ID) REFERENCES Bireysel_Kullanici(Kullanici_ID) ON DELETE CASCADE
);

CREATE TABLE Beceri (
    Beceri_ID SERIAL PRIMARY KEY,
    CV_ID INT NOT NULL,
    Beceri_Adi VARCHAR(50), 
    Seviye VARCHAR(20),
    FOREIGN KEY (CV_ID) REFERENCES CV(CV_ID) ON DELETE CASCADE
);

CREATE TABLE Referans(
    Referans_ID SERIAL PRIMARY KEY,
    CV_ID INT NOT NULL,
    Ad_Soyad VARCHAR(100),
    Iletisim_Bilgisi VARCHAR(100),
    FOREIGN KEY (CV_ID) REFERENCES CV(CV_ID) ON DELETE CASCADE
);


CREATE TABLE Is_Ilani (
    Ilan_ID SERIAL PRIMARY KEY,
    Isveren_ID INT NOT NULL,
    Baslik VARCHAR(100),
    Yayin_Tarihi DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (Isveren_ID) REFERENCES Isveren(Kullanici_ID) ON DELETE CASCADE
);

CREATE TABLE Basvuru (
    Basvuru_ID SERIAL PRIMARY KEY,
    Ilan_ID INT NOT NULL,
    Kullanici_ID INT NOT NULL,
    Basvuru_Tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Ilan_ID) REFERENCES Is_Ilani(Ilan_ID) ON DELETE CASCADE,
    FOREIGN KEY (Kullanici_ID) REFERENCES Bireysel_Kullanici(Kullanici_ID) ON DELETE CASCADE
);

-- 10 TANE VERİ GİRİŞİ
INSERT INTO Abonelik_Plani (Plan_Adi, Fiyat, Sure_Gun) VALUES
('Basic', 0.00, 30), ('Premium Deneme', 0.00, 30), ('Öğrenci Premium', 69.99, 30),
('Öğrenci Premium Yıllık', 600, 365), ('Premium', 199.0, 30), ('Premium Yıllık', 2000, 365),
('Öğrenci Premium Deneme', 0.00, 30), ('Kurumsal', 999.98, 30), ('Kurumsal Silver', 1500.00, 30),
('Kurumsal Gold', 5000.00, 365);

INSERT INTO Kullanici (Kullanici_ID, EPosta, Sifre, Kullanici_Tipi) VALUES
(1, 'k1@m.com', '123', 'Bireysel'), (2, 'k2@m.com', '123', 'Bireysel'), (3, 'k3@m.com', '123', 'Bireysel'),
(4, 's1@s.com', '123', 'Isveren'), (5, 's2@s.com', '123', 'Isveren'), (6, 'k4@m.com', '123', 'Bireysel'),
(7, 's3@s.com', '123', 'Isveren'), (8, 's4@s.com', '123', 'Isveren'), (9, 's5@s.com', '123', 'Isveren'),
(10, 'k5@m.com', '123', 'Bireysel');

INSERT INTO Bireysel_Kullanici (Kullanici_ID, Ad, Soyad) VALUES
(1, 'Kadir', 'Gümüş'), (2, 'Ayşe', 'Koşan'), (3, 'Turgut', 'Bayrakçı'), (6, 'Ahmet', 'Yılmaz'), (10, 'Nuray', 'Nurlu');

INSERT INTO Isveren (Kullanici_ID, Sirket_Adi, Sektor) VALUES
(4, 'Büyük Şirket', 'Pazarlama'), (5, 'Teknoloji Adası', 'Yazılım'), (7, 'Goggle', 'Yazılım'), (8, 'Akasya Döner', 'Gıda'), (9, 'Kariyer AŞ', 'İK');

--triggerlar

--1. otomatik fatura triggerı
CREATE OR REPLACE FUNCTION fn_fatura_olustur()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Durum= 'Başarılı' THEN
        INSERT INTO Fatura (Odeme_ID, Fatura_No, Kesim_Tarihi)
        VALUES (NEW.Odeme_ID, 'FAT-' || NEW.Odeme_ID || TO_CHAR(NOW(), 'YYYYMMDD'), CURRENT_DATE);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_odeme_sonrasi_fatura
AFTER INSERT ON Odeme
FOR EACH ROW EXECUTE FUNCTION fn_fatura_olustur();

--2. Başvuru kontrol triggerı 
CREATE OR REPLACE FUNCTION fn_basvuru_kontrol()
RETURNS TRIGGER AS $$
DECLARE
    u_tip VARCHAR;
BEGIN
    SELECT Kullanici_Tipi INTO u_tip FROM Kullanici WHERE Kullanici_ID = NEW.Kullanici_ID;
    IF u_tip = 'Isveren' THEN 
        RAISE EXCEPTION 'İşverenler iş ilanlarına başvuramaz!!!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_basvuru_tip_kontrol
BEFORE INSERT ON Basvuru
FOR EACH ROW EXECUTE FUNCTION fn_basvuru_kontrol();

--3. abonelik durum triggerı
CREATE OR REPLACE FUNCTION fn_abonelik_log()
RETURNS TRIGGER AS $$
BEGIN
     RAISE NOTICE 'Kullanici % için yeni bir abonelik başlatıldı.', NEW.Kullanici_ID;
     RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_abonelik_takip
AFTER INSERT ON Abonelik
FOR EACH ROW EXECUTE FUNCTION fn_abonelik_log();

SELECT table_name
FROM information_schema.tables
WHERE table_schema= 'public';