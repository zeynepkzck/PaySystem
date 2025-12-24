
DROP TABLE IF EXISTS Fatura, Odeme, Kredi_Karti, Havale_EFT, Odeme_Yontemi, Abonelik, Bireysel_Kullanici, Isveren, Abonelik_Plani, Kullanici CASCADE;

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

-- 10 TANE VERİ GİRİŞİ (Abonelik Planları için 10'a tamamladım)
INSERT INTO Abonelik_Plani (Plan_Adi, Fiyat, Sure_Gun) VALUES
('Basic', 0.00, 30),
('Premium Deneme', 0.00, 30),
('Öğrenci Premium', 69.99, 30),
('Öğrenci Premium Yıllık', 600, 365),
('Premium', 199.0, 30),
('Premium Yıllık', 2000, 365),
('Öğrenci Premium Deneme', 0.00, 30),
('Kurumsal', 999.98, 30),
('Kurumsal Silver', 1500.00, 30),
('Kurumsal Gold', 5000.00, 365);

-- Kullanicilar (ID çakışmasını önlemek için seri devam etmeli)
INSERT INTO Kullanici (Kullanici_ID, EPosta, Sifre, Kullanici_Tipi) VALUES
(1, 'derdinekeder@bing.com', 'ismailpro123', 'Bireysel'),
(2, 'aysekosan@mailim.com', 'sifresifresifre', 'Bireysel'),
(3, 'asaletinyeter@meyil.com', 'fetih1453', 'Bireysel'),
(4, 'cokonemlisirket@sirketim.com', 'ruhi123', 'Isveren'),
(5, 'teknolojiltdsti@yandex.com', '123sifre', 'Isveren'),
(6, 'yilmazelektrik@hotmail.com', 'yilmazyilmaz', 'Bireysel'),
(7, 'tech@goggle.com', 'admin44', 'Isveren'),
(8, 'akasyadoner@donerci.com', 'tavukdoner', 'Isveren'),
(9, 'iksirket@sirket.com', '1837837', 'Isveren'),
(10, '85calisanadam@maik.com', 'sifrem878', 'Bireysel');

-- Bireysel Kullanici Detayları
INSERT INTO Bireysel_Kullanici (Kullanici_ID, Ad, Soyad, Dogum_Tarihi, Cinsiyet) VALUES
(1, 'Kadir', 'Gümüş', '1992-05-03','Erkek'),
(2, 'Ayşe', 'Koşan', '1979-08-17','Kadın'),
(3, 'Turgut', 'Bayrakçı', '1985-01-01','Erkek'),
(6, 'Ahmet Emir', 'Yılmaz', '2000-11-30','Erkek'),
(10, 'Nuray', 'Nurlu', '1991-02-22','Kadın');

-- İşveren Detayları
INSERT INTO Isveren (Kullanici_ID, Sirket_Adi, Sektor, Web_Sitesi, Sirket_Adresi) VALUES
(4, 'Büyük Şirket', 'Pazarlama', 'www.buyuksirket.com','Istanbul/Kadıköy'),
(5, 'Teknoloji Adası', 'Yazılım', 'www.teknoada.com','Ankara/Mamak'),
(7, 'Goggle', 'Yazılım', 'www.goggle.com','Manisa/Yunusemre'),
(8, 'Akasya Döner', 'Döner', 'yok','İzmir/Menemen'),
(9, 'Kariyer AŞ', 'İnsan Kaynakları', 'www.kariyeryap.com', 'Erzurum/Merkez');