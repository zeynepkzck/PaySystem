-- TABLOLARI SIFIRLAMA (CASCADE sayesinde her şey temizlenir)
DROP TABLE IF EXISTS Fatura, Kredi_Kartı, Kupon_Odeme, Odeme, Odeme_Yontemi, Basvuru, Ilan, Referans, Kullanici_Beceri, Beceri, Egitim_Kayit, Egitim_Ilani, Egitim_Bilgisi, Okular, Bolum, CV, ProjeUser, Proje, Kullanici_Abonelik, Sirket, Bireysel_Kullanici, Abonelik_Planı, Kullanici, Kupon CASCADE;

-- KULLANICI VE HİYERARŞİ 
CREATE TABLE Kullanici (
    Kullanici_ID INT PRIMARY KEY,
    Eposta VARCHAR(100) UNIQUE NOT NULL,
    Sifre VARCHAR(50) NOT NULL,
    Kullanici_Tipi VARCHAR(20), -- "Bireysel" veya "Sirket"
    Status VARCHAR(10) DEFAULT 'Active',
    CreateDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Bireysel_Kullanici (
    Kullanici_ID INT PRIMARY KEY,
    Ad VARCHAR(50) NOT NULL,
    Soyad VARCHAR(50) NOT NULL,
    Dogum_Tarihi DATE,
    Profil_Gorunurlugu BOOLEAN DEFAULT TRUE,
    Status VARCHAR(10) DEFAULT 'Active',
    FOREIGN KEY (Kullanici_ID) REFERENCES Kullanici(Kullanici_ID) ON DELETE CASCADE
);

CREATE TABLE Sirket (
    Kullanici_ID INT PRIMARY KEY,
    Sirket_Adi VARCHAR(100) NOT NULL,
    Sektor VARCHAR(50),
    Vergi_No VARCHAR(20),
    Status VARCHAR(10) DEFAULT 'Active',
    FOREIGN KEY (Kullanici_ID) REFERENCES Kullanici(Kullanici_ID) ON DELETE CASCADE
);

-- 2. KARİYER VE İLAN (Beceri ara tablosu ve Referans yer değişimi dahil)
CREATE TABLE CV (
    CV_ID SERIAL PRIMARY KEY,
    CV_Adi VARCHAR(100),
    Kullanici_ID INT NOT NULL,
    Olusturma_Tarihi DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (Kullanici_ID) REFERENCES Bireysel_Kullanici(Kullanici_ID) ON DELETE CASCADE
);

CREATE TABLE Beceri (
    Beceri_ID SERIAL PRIMARY KEY,
    Beceri_Adi VARCHAR(50) NOT NULL,
    Beceri_Tipi VARCHAR(50)
);

CREATE TABLE Kullanici_Beceri (
    Kullanici_ID INT NOT NULL,
    Beceri_ID INT NOT NULL,
    Seviye VARCHAR(20),
    PRIMARY KEY (Kullanici_ID, Beceri_ID),
    FOREIGN KEY (Kullanici_ID) REFERENCES Bireysel_Kullanici(Kullanici_ID) ON DELETE CASCADE,
    FOREIGN KEY (Beceri_ID) REFERENCES Beceri(Beceri_ID) ON DELETE CASCADE
);

CREATE TABLE Ilan (
    Ilan_ID SERIAL PRIMARY KEY,
    Sirket_ID INT NOT NULL,
    Baslik VARCHAR(100) NOT NULL,
    Aciklama TEXT,
    Yayin_Tarihi DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (Sirket_ID) REFERENCES Sirket(Kullanici_ID) ON DELETE CASCADE
);

CREATE TABLE Basvuru (
    Basvuru_ID SERIAL PRIMARY KEY,
    Ilan_ID INT NOT NULL,
    Kullanici_ID INT NOT NULL,
    CV_ID INT NOT NULL,
    Basvuru_Tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Ilan_ID) REFERENCES Ilan(Ilan_ID) ON DELETE CASCADE,
    FOREIGN KEY (Kullanici_ID) REFERENCES Bireysel_Kullanici(Kullanici_ID) ON DELETE CASCADE,
    FOREIGN KEY (CV_ID) REFERENCES CV(CV_ID) ON DELETE CASCADE
);

-- 3. FİNANS VE ABONELİK (Kullanici_Abonelik ve subtype'lar)
CREATE TABLE Abonelik_Planı (
    Plan_ID SERIAL PRIMARY KEY,
    Plan_Adi VARCHAR(50) NOT NULL,
    Fiyat DECIMAL(10,2) NOT NULL,
    Sure INT,
    Kullanici_Tipi VARCHAR(20)
);

CREATE TABLE Kullanici_Abonelik (
    Abonelik_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT NOT NULL,
    Plan_ID INT NOT NULL,
    Baslangic_Tarihi DATE DEFAULT CURRENT_DATE,
    Status VARCHAR(10) DEFAULT 'Active',
    FOREIGN KEY (Kullanici_ID) REFERENCES Kullanici(Kullanici_ID) ON DELETE CASCADE,
    FOREIGN KEY (Plan_ID) REFERENCES Abonelik_Planı(Plan_ID)
);

CREATE TABLE Odeme_Yontemi (
    Yontem_ID SERIAL PRIMARY KEY,
    Yontem_Adi VARCHAR(50) NOT NULL
);

CREATE TABLE Odeme (
    Odeme_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT NOT NULL,
    Tutar DECIMAL(10,2) NOT NULL,
    Tarih TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Odeme_YontemiID INT NOT NULL,
    AcceptedStatus BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (Kullanici_ID) REFERENCES Kullanici(Kullanici_ID),
    FOREIGN KEY (Odeme_YontemiID) REFERENCES Odeme_Yontemi(Yontem_ID)
);

CREATE TABLE Fatura (
    Fatura_ID SERIAL PRIMARY KEY,
    Odeme_ID INT UNIQUE NOT NULL,
    Fatura_No VARCHAR(50) UNIQUE NOT NULL,
    Kesim_Tarihi DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (Odeme_ID) REFERENCES Odeme(Odeme_ID) ON DELETE CASCADE
);

CREATE TABLE Kredi_Kartı (
    Odeme_ID INT PRIMARY KEY,
    Kart_No VARCHAR(16) NOT NULL,
    Son_Kullanma VARCHAR(5) NOT NULL,
    CVV VARCHAR(3) NOT NULL,
    FOREIGN KEY (Odeme_ID) REFERENCES Odeme(Odeme_ID) ON DELETE CASCADE
);

--Insertler

-- Abonelik Planları (Orijinal 10 veri)
INSERT INTO Abonelik_Planı (Plan_Adi, Fiyat, Sure, Kullanici_Tipi) VALUES
('Basic', 0.00, 30, 'Bireysel'), ('Premium Deneme', 0.00, 30, 'Bireysel'),
('Öğrenci Premium', 69.99, 30, 'Bireysel'), ('Öğrenci Premium Yıllık', 600, 365, 'Bireysel'),
('Premium', 199.0, 30, 'Bireysel'), ('Premium Yıllık', 2000, 365, 'Bireysel'),
('Öğrenci Premium Deneme', 0.00, 30, 'Bireysel'), ('Kurumsal', 999.98, 30, 'Sirket'),
('Kurumsal Silver', 1500.00, 30, 'Sirket'), ('Kurumsal Gold', 5000.00, 365, 'Sirket');

-- Kullanıcılar 
INSERT INTO Kullanici (Kullanici_ID, Eposta, Sifre, Kullanici_Tipi) VALUES
(1, 'derdinekeder@bing.com', 'ismailpro123', 'Bireysel'),
(2, 'aysekosan@mailim.com', 'sifresifresifre', 'Bireysel'),
(3, 'asaletinyeter@meyil.com', 'fetih1453', 'Bireysel'),
(4, 'cokonemlisirket@sirketim.com', 'ruhi123', 'Sirket'),
(5, 'teknolojiltdsti@yandex.com', '123sifre', 'Sirket'),
(6, 'yilmazelektrik@hotmail.com', 'yilmazyilmaz', 'Bireysel'),
(7, 'tech@goggle.com', 'admin44', 'Sirket'),
(8, 'akasyadoner@donerci.com', 'tavukdoner', 'Sirket'),
(9, 'iksirket@sirket.com', '1837837', 'Sirket'),
(10, '85calisanadam@maik.com', 'sifrem878', 'Bireysel');

-- Bireysel Kullanıcı Detayları 
INSERT INTO Bireysel_Kullanici (Kullanici_ID, Ad, Soyad, Dogum_Tarihi) VALUES
(1, 'Kadir', 'Gümüş', '1992-05-03'), (2, 'Ayşe', 'Koşan', '1979-08-17'),
(3, 'Turgut', 'Bayrakçı', '1985-01-01'), (6, 'Ahmet Emir', 'Yılmaz', '2000-11-30'),
(10, 'Nuray', 'Nurlu', '1991-02-22');

-- Şirket Detayları 
INSERT INTO Sirket (Kullanici_ID, Sirket_Adi, Sektor) VALUES
(4, 'Büyük Şirket', 'Pazarlama'), (5, 'Teknoloji Adası', 'Yazılım'),
(7, 'Goggle', 'Yazılım'), (8, 'Akasya Döner', 'Gıda'),
(9, 'Kariyer AŞ', 'İK');

-- Beceri ve Diğer Modüller 
INSERT INTO Beceri (Beceri_Adi, Beceri_Tipi) VALUES ('SQL', 'Teknik'), ('Liderlik', 'Sosyal');
INSERT INTO CV (CV_Adi, Kullanici_ID) VALUES ('Yazılım Geliştirici CV', 1);
INSERT INTO Ilan (Sirket_ID, Baslik) VALUES (5, 'Yazılım Mühendisi Aranıyor');
INSERT INTO Odeme_Yontemi (Yontem_Adi) VALUES ('Kredi Kartı'), ('Havale/EFT');

-- TRIGGERLAR 
CREATE OR REPLACE FUNCTION fn_fatura_olustur()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.AcceptedStatus = TRUE THEN
        INSERT INTO Fatura (Odeme_ID, Fatura_No, Kesim_Tarihi)
        VALUES (NEW.Odeme_ID, 'FAT-' || NEW.Odeme_ID || TO_CHAR(NOW(), 'YYYYMMDD'), CURRENT_DATE);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_odeme_sonrasi_fatura
AFTER INSERT ON Odeme
FOR EACH ROW EXECUTE FUNCTION fn_fatura_olustur();

CREATE OR REPLACE FUNCTION fn_basvuru_kontrol()
RETURNS TRIGGER AS $$
DECLARE
    u_tip VARCHAR;
BEGIN
    SELECT Kullanici_Tipi INTO u_tip FROM Kullanici WHERE Kullanici_ID = NEW.Kullanici_ID;
    IF u_tip = 'Sirket' THEN 
        RAISE EXCEPTION 'Şirketler iş ilanlarına başvuramaz!!!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_basvuru_tip_kontrol
BEFORE INSERT ON Basvuru
FOR EACH ROW EXECUTE FUNCTION fn_basvuru_kontrol();