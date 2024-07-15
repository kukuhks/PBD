-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 15, 2024 at 04:31 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pbd_rentalmobil`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMobilByTypeAndYear` (IN `tipe` CHAR(5), IN `tahun` INT(5))   BEGIN
IF tipe IS NOT NULL THEN
	SELECT * FROM mobil WHERE kd_tipe = tipe AND tahun_keluar = tahun; 
ELSE
	SELECT * FROM mobil WHERE tahun_keluar = tahun;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ShowAllDrivers` ()   BEGIN
	SELECT * FROM driver;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_hitungDenda` (`kd_peminjaman` CHAR(5), `tgl_pengembalian` DATE) RETURNS INT(11)  BEGIN
	DECLARE tgl_kembali DATE;
    DECLARE id_mobil_new INT;
    DECLARE denda_per_hari INT;
    DECLARE total_denda INT;

    SELECT p.tgl_kembali, p.id_mobil INTO tgl_kembali, id_mobil_new
    FROM peminjaman p
    WHERE p.kd_peminjaman = kd_peminjaman;
    
    SELECT m.denda INTO denda_per_hari
    FROM mobil m
    WHERE m.id_mobil = id_mobil_new;
    
    SET total_denda = 0;

    IF tgl_pengembalian > tgl_kembali THEN
    	SET total_denda = DATEDIFF(tgl_pengembalian, tgl_kembali) * denda_per_hari;
    END IF;
    
    RETURN total_denda;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_jumlahPetugas` () RETURNS INT(11)  BEGIN
 	DECLARE jumlah_petugas INT;
    SELECT COUNT(*) INTO jumlah_petugas FROM petugas;
    RETURN jumlah_petugas;
 END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `driver`
--

CREATE TABLE `driver` (
  `id_driver` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `alamat` varchar(200) DEFAULT NULL,
  `gaji` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `driver`
--

INSERT INTO `driver` (`id_driver`, `nama`, `no_telp`, `alamat`, `gaji`) VALUES
(1, 'Abdi', '081122223333', 'Bantul', 500000.00),
(2, 'Budi', '082233334444', 'Sleman', 400000.00),
(3, 'Cahyadi', '083344445555', 'Bantul', 450000.00),
(4, 'Dedi', '084455556666', 'Sleman', 400000.00),
(5, 'Edi', '085566667777', 'Yogyakarta', 500000.00),
(6, 'Jono', '0812322211234', 'Bantul', 500000.00),
(7, 'Gilang', '089912214565', 'Sleman', 450000.00),
(8, 'Fahmi', '087722134554', 'Wates', 500000.00);

--
-- Triggers `driver`
--
DELIMITER $$
CREATE TRIGGER `after_insert_driver` AFTER INSERT ON `driver` FOR EACH ROW BEGIN
	insert into driver_log (id_driver, nama, no_telp, alamat, gaji, date_inputed) 
    values (new.id_driver, new.nama, new.no_telp, new.alamat, new.gaji, now());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_driver` BEFORE INSERT ON `driver` FOR EACH ROW BEGIN
    IF NEW.gaji < 400000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gaji tidak boleh kurang dari 400000';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `driver_log`
--

CREATE TABLE `driver_log` (
  `id_driver` int(11) DEFAULT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `alamat` varchar(200) DEFAULT NULL,
  `gaji` decimal(10,2) DEFAULT NULL,
  `date_inputed` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `driver_log`
--

INSERT INTO `driver_log` (`id_driver`, `nama`, `no_telp`, `alamat`, `gaji`, `date_inputed`) VALUES
(7, 'Gilang', '089912214565', 'Sleman', 450000.00, '2024-07-15'),
(8, 'Fahmi', '087722134554', 'Wates', 500000.00, '2024-07-15');

-- --------------------------------------------------------

--
-- Table structure for table `investor`
--

CREATE TABLE `investor` (
  `id_investor` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `jenis_kelamin` enum('L','P') DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `alamat` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `investor`
--

INSERT INTO `investor` (`id_investor`, `nama`, `jenis_kelamin`, `no_telp`, `alamat`) VALUES
(1, 'Ahmad Haitsam', 'L', '082143546576', 'Sleman'),
(2, 'Bintang Pratama', 'L', '082332455456', 'Sleman'),
(3, 'Sekar Kurniadi', 'P', '088998788776', 'Kulon Progo'),
(4, 'Nissa Maharani', 'P', '085665766745', 'Yogyakarta'),
(5, 'Farhan Yudhayana', 'L', '085445344332', 'Bantul');

-- --------------------------------------------------------

--
-- Table structure for table `mobil`
--

CREATE TABLE `mobil` (
  `id_mobil` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `no_plat` varchar(15) DEFAULT NULL,
  `kursi` int(3) DEFAULT NULL,
  `tahun_keluar` int(5) DEFAULT NULL,
  `harga` int(11) DEFAULT NULL,
  `denda` int(11) DEFAULT NULL,
  `id_investor` int(11) DEFAULT NULL,
  `kd_tipe` char(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mobil`
--

INSERT INTO `mobil` (`id_mobil`, `nama`, `no_plat`, `kursi`, `tahun_keluar`, `harga`, `denda`, `id_investor`, `kd_tipe`) VALUES
(1, 'Toyota Avanza', 'AB 6969 AV', 7, 2023, 400000, 40000, 1, 'FML'),
(2, 'Toyota Hiace', 'AB 1961 HI', 16, 2019, 800000, 80000, 2, 'MNB'),
(3, 'Honda Jazz', 'AB 2323 JZ', 5, 2018, 450000, 45000, 3, 'CTY'),
(4, 'Honda Brio', 'AB 1234 BR', 5, 2018, 300000, 30000, 4, 'CTY'),
(5, 'Mitsubishi Pajero', 'B 2077 PJR', 7, 2020, 1500000, 150000, 5, 'SUV'),
(6, 'Suzuki Ertiga', 'AB 6666 ER', 7, 2021, 400000, 40000, 1, 'FML'),
(7, 'Toyota Innova Reborn', 'AB 8293 IN', 7, 2020, 600000, 60000, 3, 'FML');

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `id_pelanggan` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `jenis_kelamin` enum('L','P') DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `alamat` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pelanggan`
--

INSERT INTO `pelanggan` (`id_pelanggan`, `nama`, `jenis_kelamin`, `no_telp`, `alamat`) VALUES
(1, 'Kukuh Setiadi', 'L', '081234567890', 'Magelang'),
(2, 'Nizar Mohammad', 'L', '081234567890', 'Sleman'),
(3, 'Jenderal Nicolas', 'L', '081234567890', 'Sleman'),
(4, 'Fauzan Yahya', 'L', '081234567890', 'Sleman'),
(5, 'Fisan Syafa', 'L', '081234567890', 'Bantul'),
(6, 'Guntur', 'L', '08123456789', 'Lampung');

-- --------------------------------------------------------

--
-- Table structure for table `peminjaman`
--

CREATE TABLE `peminjaman` (
  `kd_peminjaman` char(5) NOT NULL,
  `tgl_pinjam` date DEFAULT NULL,
  `tgl_kembali` date DEFAULT NULL,
  `durasi` int(3) NOT NULL,
  `dengan_driver` enum('Ya','Tidak') NOT NULL,
  `jaminan` varchar(30) DEFAULT NULL,
  `id_pelanggan` int(11) DEFAULT NULL,
  `id_mobil` int(11) DEFAULT NULL,
  `id_petugas` int(11) DEFAULT NULL,
  `id_driver` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `peminjaman`
--

INSERT INTO `peminjaman` (`kd_peminjaman`, `tgl_pinjam`, `tgl_kembali`, `durasi`, `dengan_driver`, `jaminan`, `id_pelanggan`, `id_mobil`, `id_petugas`, `id_driver`) VALUES
('P0001', '2024-06-20', '2024-06-22', 2, 'Ya', '-', 1, 1, 5, 1),
('P0002', '2024-06-21', '2024-06-22', 1, 'Ya', '-', 2, 7, 3, 2),
('P0003', '2024-06-23', '2024-06-25', 2, 'Ya', '-', 3, 5, 4, 3),
('P0004', '2024-06-24', '2024-06-27', 3, 'Ya', '-', 4, 2, 1, 4),
('P0005', '2024-06-29', '2024-06-30', 1, 'Ya', '-', 5, 4, 2, 5),
('P0006', '2024-07-01', '2024-07-07', 6, 'Tidak', 'Motor', 3, 1, 2, NULL),
('P0007', '2024-07-06', '2024-07-09', 3, 'Tidak', 'KTP', 4, 3, 4, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pengembalian`
--

CREATE TABLE `pengembalian` (
  `id_pengembalian` int(11) NOT NULL,
  `tgl_pengembalian` date DEFAULT NULL,
  `total_denda` int(11) DEFAULT NULL,
  `kd_peminjaman` char(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengembalian`
--

INSERT INTO `pengembalian` (`id_pengembalian`, `tgl_pengembalian`, `total_denda`, `kd_peminjaman`) VALUES
(1, '2024-06-22', 0, 'P0001'),
(2, '2024-06-22', 0, 'P0002'),
(3, '2024-06-25', 0, 'P0003'),
(4, '2024-06-29', 160000, 'P0004'),
(5, '2024-06-30', 0, 'P0005'),
(6, '2024-07-07', 0, 'P0006'),
(7, '2024-07-10', 45000, 'P0007');

--
-- Triggers `pengembalian`
--
DELIMITER $$
CREATE TRIGGER `after_update_pengembalian` AFTER UPDATE ON `pengembalian` FOR EACH ROW BEGIN
	insert into pengembalian_log (id_pengembalian, kd_peminjaman, tgl_pengembalian_lama, tgl_pengembalian_baru, total_denda_lama, total_denda_baru, date_updated)
    values
    (old.id_pengembalian, old.kd_peminjaman, old.tgl_pengembalian, new.tgl_pengembalian, old.total_denda, new.total_denda, now());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_pengembalian` BEFORE UPDATE ON `pengembalian` FOR EACH ROW BEGIN
    DECLARE total_denda INT;

    SELECT 
        CASE
            WHEN NEW.tgl_pengembalian > p.tgl_kembali THEN DATEDIFF(NEW.tgl_pengembalian, p.tgl_kembali) * m.denda
            ELSE 0
        END INTO total_denda
    FROM 
        peminjaman p
    JOIN 
        mobil m ON p.id_mobil = m.id_mobil
    WHERE 
        p.kd_peminjaman = NEW.kd_peminjaman;

    SET NEW.total_denda = total_denda;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pengembalian_log`
--

CREATE TABLE `pengembalian_log` (
  `id_pengembalian` int(11) DEFAULT NULL,
  `kd_peminjaman` char(5) DEFAULT NULL,
  `tgl_pengembalian_lama` date DEFAULT NULL,
  `tgl_pengembalian_baru` date DEFAULT NULL,
  `total_denda_lama` int(11) DEFAULT NULL,
  `total_denda_baru` int(11) DEFAULT NULL,
  `date_updated` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengembalian_log`
--

INSERT INTO `pengembalian_log` (`id_pengembalian`, `kd_peminjaman`, `tgl_pengembalian_lama`, `tgl_pengembalian_baru`, `total_denda_lama`, `total_denda_baru`, `date_updated`) VALUES
(4, 'P0004', '2024-06-29', '2024-06-29', 160000, 160000, '2024-07-15');

-- --------------------------------------------------------

--
-- Table structure for table `petugas`
--

CREATE TABLE `petugas` (
  `id_petugas` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `alamat` varchar(200) DEFAULT NULL,
  `gaji` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `petugas`
--

INSERT INTO `petugas` (`id_petugas`, `nama`, `no_telp`, `alamat`, `gaji`) VALUES
(1, 'Ageng', '088899990000', 'Yogyakarta', 1000000.00),
(2, 'Bella', '088877776666', 'Sleman', 1500000.00),
(3, 'Chandra', '088855554444', 'Yogyakarta', 2000000.00),
(4, 'Dimas', '088833332222', 'Sleman', 1500000.00),
(5, 'Eva', '088811115555', 'Sleman', 1200000.00);

-- --------------------------------------------------------

--
-- Table structure for table `tipe_mobil`
--

CREATE TABLE `tipe_mobil` (
  `kd_tipe` char(5) NOT NULL,
  `nama` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tipe_mobil`
--

INSERT INTO `tipe_mobil` (`kd_tipe`, `nama`) VALUES
('CTY', 'City Car'),
('FML', 'Family Car'),
('MNB', 'Minibus'),
('PCK', 'Pickup'),
('SUV', 'SUV');

-- --------------------------------------------------------

--
-- Table structure for table `ulasan`
--

CREATE TABLE `ulasan` (
  `id_ulasan` int(11) NOT NULL,
  `pesan` text DEFAULT NULL,
  `id_pelanggan` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ulasan`
--

INSERT INTO `ulasan` (`id_ulasan`, `pesan`, `id_pelanggan`) VALUES
(1, 'Pelayanannya sangat memuaskan, mobilnya bersih dan nyaman.', 1),
(2, 'Drivernya sangat ramah dan asik, membuat perjalanan menjadi menyenangkan.', 2),
(3, 'Mobil terawat dengan baik, bersih dan nyaman untuk digunakan.', 4),
(5, 'Saya sudah 2 kali menggunakan jasa rental mobil ini, saya sangat puas dan akan merekomendasikannya ke keluarga dan teman.', 3);

--
-- Triggers `ulasan`
--
DELIMITER $$
CREATE TRIGGER `after_delete_ulasan` AFTER DELETE ON `ulasan` FOR EACH ROW BEGIN
    INSERT INTO ulasan_log (id_ulasan, pesan, id_pelanggan, date_deleted)
    VALUES (OLD.id_ulasan, OLD.pesan, OLD.id_pelanggan, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_review` BEFORE DELETE ON `ulasan` FOR EACH ROW BEGIN
    INSERT into ulasan_log (id_ulasan, pesan, id_pelanggan, date_deleted)
    values (old.id_ulasan, old.pesan, old.id_pelanggan, NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ulasan_log`
--

CREATE TABLE `ulasan_log` (
  `id_ulasan` int(11) DEFAULT NULL,
  `pesan` text DEFAULT NULL,
  `id_pelanggan` int(11) DEFAULT NULL,
  `date_deleted` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ulasan_log`
--

INSERT INTO `ulasan_log` (`id_ulasan`, `pesan`, `id_pelanggan`, `date_deleted`) VALUES
(4, 'Mobil yang saya dapat cukup kotor, mohon untuk dibersihkan kembali.', 5, '2024-07-15'),
(4, 'Mobil yang saya dapat cukup kotor, mohon untuk dibersihkan kembali.', 5, '2024-07-15');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_datapelanggan`
-- (See below for the actual view)
--
CREATE TABLE `v_datapelanggan` (
`nama` varchar(100)
,`jenis_kelamin` enum('L','P')
,`alamat` varchar(200)
,`no_telp` varchar(20)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_peminjamanpelanggan`
-- (See below for the actual view)
--
CREATE TABLE `v_peminjamanpelanggan` (
`nama` varchar(100)
,`alamat` varchar(200)
,`no_telp` varchar(20)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_tahunmobil`
-- (See below for the actual view)
--
CREATE TABLE `v_tahunmobil` (
`id_mobil` int(11)
,`nama` varchar(100)
,`no_plat` varchar(15)
,`kursi` int(3)
,`tahun_keluar` int(5)
,`harga` int(11)
,`denda` int(11)
,`id_investor` int(11)
,`kd_tipe` char(5)
);

-- --------------------------------------------------------

--
-- Structure for view `v_datapelanggan`
--
DROP TABLE IF EXISTS `v_datapelanggan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_datapelanggan`  AS SELECT `pelanggan`.`nama` AS `nama`, `pelanggan`.`jenis_kelamin` AS `jenis_kelamin`, `pelanggan`.`alamat` AS `alamat`, `pelanggan`.`no_telp` AS `no_telp` FROM `pelanggan` ;

-- --------------------------------------------------------

--
-- Structure for view `v_peminjamanpelanggan`
--
DROP TABLE IF EXISTS `v_peminjamanpelanggan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_peminjamanpelanggan`  AS SELECT `p`.`nama` AS `nama`, `p`.`alamat` AS `alamat`, `dp`.`no_telp` AS `no_telp` FROM (`v_datapelanggan` `dp` join `pelanggan` `p` on(`dp`.`nama` = `p`.`nama`)) WHERE `dp`.`nama` = 'Fauzan Yahya'WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `v_tahunmobil`
--
DROP TABLE IF EXISTS `v_tahunmobil`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_tahunmobil`  AS SELECT `mobil`.`id_mobil` AS `id_mobil`, `mobil`.`nama` AS `nama`, `mobil`.`no_plat` AS `no_plat`, `mobil`.`kursi` AS `kursi`, `mobil`.`tahun_keluar` AS `tahun_keluar`, `mobil`.`harga` AS `harga`, `mobil`.`denda` AS `denda`, `mobil`.`id_investor` AS `id_investor`, `mobil`.`kd_tipe` AS `kd_tipe` FROM `mobil` WHERE `mobil`.`tahun_keluar` >= 2020 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `driver`
--
ALTER TABLE `driver`
  ADD PRIMARY KEY (`id_driver`);

--
-- Indexes for table `investor`
--
ALTER TABLE `investor`
  ADD PRIMARY KEY (`id_investor`);

--
-- Indexes for table `mobil`
--
ALTER TABLE `mobil`
  ADD PRIMARY KEY (`id_mobil`),
  ADD KEY `id_investor` (`id_investor`),
  ADD KEY `kd_tipe` (`kd_tipe`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`id_pelanggan`);

--
-- Indexes for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD PRIMARY KEY (`kd_peminjaman`),
  ADD KEY `id_pelanggan` (`id_pelanggan`),
  ADD KEY `id_mobil` (`id_mobil`),
  ADD KEY `id_petugas` (`id_petugas`),
  ADD KEY `id_driver` (`id_driver`);

--
-- Indexes for table `pengembalian`
--
ALTER TABLE `pengembalian`
  ADD PRIMARY KEY (`id_pengembalian`),
  ADD KEY `kd_peminjaman` (`kd_peminjaman`),
  ADD KEY `idx_tgl_denda` (`tgl_pengembalian`,`total_denda`),
  ADD KEY `idx_pengembalian_peminjaman` (`tgl_pengembalian`,`kd_peminjaman`),
  ADD KEY `idx_denda_peminjaman` (`total_denda`,`kd_peminjaman`);

--
-- Indexes for table `petugas`
--
ALTER TABLE `petugas`
  ADD PRIMARY KEY (`id_petugas`);

--
-- Indexes for table `tipe_mobil`
--
ALTER TABLE `tipe_mobil`
  ADD PRIMARY KEY (`kd_tipe`);

--
-- Indexes for table `ulasan`
--
ALTER TABLE `ulasan`
  ADD PRIMARY KEY (`id_ulasan`),
  ADD KEY `id_pelanggan` (`id_pelanggan`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `driver`
--
ALTER TABLE `driver`
  MODIFY `id_driver` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `investor`
--
ALTER TABLE `investor`
  MODIFY `id_investor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `mobil`
--
ALTER TABLE `mobil`
  MODIFY `id_mobil` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `pelanggan`
--
ALTER TABLE `pelanggan`
  MODIFY `id_pelanggan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `pengembalian`
--
ALTER TABLE `pengembalian`
  MODIFY `id_pengembalian` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `petugas`
--
ALTER TABLE `petugas`
  MODIFY `id_petugas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `ulasan`
--
ALTER TABLE `ulasan`
  MODIFY `id_ulasan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `mobil`
--
ALTER TABLE `mobil`
  ADD CONSTRAINT `mobil_ibfk_1` FOREIGN KEY (`id_investor`) REFERENCES `investor` (`id_investor`),
  ADD CONSTRAINT `mobil_ibfk_2` FOREIGN KEY (`kd_tipe`) REFERENCES `tipe_mobil` (`kd_tipe`);

--
-- Constraints for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD CONSTRAINT `peminjaman_ibfk_1` FOREIGN KEY (`id_pelanggan`) REFERENCES `pelanggan` (`id_pelanggan`),
  ADD CONSTRAINT `peminjaman_ibfk_2` FOREIGN KEY (`id_mobil`) REFERENCES `mobil` (`id_mobil`),
  ADD CONSTRAINT `peminjaman_ibfk_3` FOREIGN KEY (`id_petugas`) REFERENCES `petugas` (`id_petugas`),
  ADD CONSTRAINT `peminjaman_ibfk_4` FOREIGN KEY (`id_driver`) REFERENCES `driver` (`id_driver`);

--
-- Constraints for table `pengembalian`
--
ALTER TABLE `pengembalian`
  ADD CONSTRAINT `pengembalian_ibfk_1` FOREIGN KEY (`kd_peminjaman`) REFERENCES `peminjaman` (`kd_peminjaman`);

--
-- Constraints for table `ulasan`
--
ALTER TABLE `ulasan`
  ADD CONSTRAINT `ulasan_ibfk_1` FOREIGN KEY (`id_pelanggan`) REFERENCES `pelanggan` (`id_pelanggan`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
