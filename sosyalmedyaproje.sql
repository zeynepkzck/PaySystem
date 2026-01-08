--tabloları sıfırlama
DROP TABLE IF EXISTS Fatura, Kredi_Kartı, Kupon_Odeme, Odeme, Odeme_Yontemi, Basvuru, Ilan, Referans, Kullanici_Beceri, Beceri, Egitim_Kayit, Egitim_Ilani, Egitim_Bilgisi, Okular, Bolum, CV, ProjeUser, Proje, Kullanici_Abonelik, Sirket, Bireysel_Kullanici, Abonelik_Planı, Kullanici, Kupon CASCADE;


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
	Status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (Ilan_ID) REFERENCES Ilan(Ilan_ID) ON DELETE CASCADE,
    FOREIGN KEY (Kullanici_ID) REFERENCES Bireysel_Kullanici(Kullanici_ID) ON DELETE CASCADE,
    FOREIGN KEY (CV_ID) REFERENCES CV(CV_ID) ON DELETE CASCADE
);


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

CREATE TABLE Kupon (
    Kupon_ID SERIAL PRIMARY KEY,
    Kupon_Kodu VARCHAR(20) UNIQUE NOT NULL,
    Bitis_Suresi DATE,
    Status VARCHAR(10) DEFAULT 'Active'
);

--INSERTLER

-- Abonelik Planları
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
INSERT INTO Kupon (Kupon_Kodu, Bitis_Suresi, Status) VALUES ('kuponkupon', '2026-01-01', 'Active');

--UPDATE

--bir abonelik planının fiyatını güncelleme
UPDATE Abonelik_Planı SET Fiyat =250.00 WHERE Plan_Adi= 'Premium';
--şirketin sektör bilgisini değiştirme
UPDATE Sirket SET Sektor= 'Yapay Zeka' WHERE Sirket_Adi= 'Büyük Şirket';

--DELETE

--süresi geçmiş bir kuponu silme
DELETE FROM Kupon WHERE Bitis_Suresi<CURRENT_DATE;

--iptal edilen başvuruyu sistemden kaldırma
DELETE FROM Basvuru WHERE Status= 'İptal';

--SELECT SORGULARI

--her sektördeki toplam şirket sayısını bul
SELECT Sektor, COUNT(Kullanici_ID) as Toplam_Sirket
FROM Sirket
GROUP BY Sektor;

--her planın kaç kullanıcısı olduğunu ve toplam kazancı listeler
SELECT AP.Plan_Adi, COUNT(KA.Kullanici_ID) as Kullanici_Sayisi, SUM(AP.Fiyat) as Toplam_Gelir
FROM Abonelik_Planı AP
LEFT JOIN Kullanici_Abonelik KA ON AP.Plan_ID = KA.Plan_ID
GROUP BY AP.Plan_Adi;

--hangi kullanıcının hangi planda olduğunu gösterir
SELECT K.Eposta, AP.Plan_Adi, AP.Fiyat
FROM Kullanici K
JOIN Kullanici_Abonelik KA ON K.Kullanici_ID=KA.Kullanici_ID
JOIN Abonelik_Planı AP ON KA.Plan_ID= AP.Plan_ID;

--şirket başına açılan toplam ilan sayısını göster
SELECT S.Sirket_Adi, COUNT(I.Ilan_ID) as Ilan_Sayisi
FROM Sirket S
LEFT JOIN Ilan I ON S.Kullanici_ID= I.Sirket_ID
GROUP BY S.Sirket_Adi;

--başarılı tüm ödemelerin toplam tutarı
SELECT SUM(Tutar) as Toplam_Ciro 
FROM Odeme 
WHERE AcceptedStatus = TRUE;

--kullanıcıların e-postaları ve sahip oldukları toplam beceri sayısını listeler
SELECT K.Eposta, COUNT(KB.Beceri_ID) as Toplam_Beceri
FROM Kullanici K
JOIN Kullanici_Beceri KB ON K.Kullanici_ID = KB.Kullanici_ID
GROUP BY K.Eposta;

--belirli bir ilana yapılan başvuru sayısı
SELECT I.Baslik, BK.Ad, BK.Soyad
FROM Ilan I
JOIN Basvuru B ON I.Ilan_ID= B.Ilan_ID
JOIN Bireysel_Kullanici BK ON B.Kullanici_ID= BK.Kullanici_ID;

--ortalama ödeme miktarından daha fazla ödeme yapan kullanıcıyı bul
SELECT Eposta FROM Kullanici 
WHERE Kullanici_ID IN (
    SELECT Kullanici_ID FROM Odeme 
    WHERE Tutar > (SELECT AVG(Tutar) FROM Odeme)
);


--hiç iş başvurusu yapmamış olan kullanıcıların isimleri
SELECT Ad, Soyad 
FROM Bireysel_Kullanici 
WHERE Kullanici_ID NOT IN (SELECT Kullanici_ID FROM Basvuru);

--yazılım sektöründeki şirketlerin ilanlarına başvuran kullanıcıların e-postaları
SELECT Eposta FROM Kullanici 
WHERE Kullanici_ID IN (
    SELECT Kullanici_ID FROM Basvuru 
    WHERE Ilan_ID IN (
        SELECT Ilan_ID FROM Ilan 
        WHERE Sirket_ID IN (SELECT Kullanici_ID FROM Sirket WHERE Sektor = 'Yazılım')
    )
);

-- TRIGGERLAR 

--başarılı ödeme ardından fatura oluşturma triggerı
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

--otomatik ödeme güncelleme triggerı
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.UpdateDate = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_kullanici_guncelleme_tarihi
BEFORE UPDATE ON Kullanici
FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_odeme_sonrasi_fatura
AFTER INSERT ON Odeme
FOR EACH ROW EXECUTE FUNCTION fn_fatura_olustur();

--sirketlerin iş ilanlarına başvurmasını engelleyen trigger
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