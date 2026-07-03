<?php
$conect = mysqli_connect('localhost', 'root', '', 'finance');
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');

// pengecekan request client
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $sql = 'select * from catatan_keuangan';
    
    // baca dari database
    $result = mysqli_query($conect, $sql);
    
    // simpan dalam bentuk array
    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }
    
    echo json_encode($data);
}else if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // ambil data dari request body
    $input = json_decode(file_get_contents('php://input'), true);
    
    //ambil nominal dari kategori
    $nominal = $input['nominal'];
    $kategori = $input['kategori'];

    // simpan ke database
    $sql = "INSERT INTO catatan_keuangan (nominal, kategori) VALUES ('{$nominal}', '{$kategori}')";
    $result =mysqli_query($conect, $sql);
    
    if ($result) {
    echo json_encode(array('status' => 'sukses', 'message' => 'Data berhasil disimpan'));
    } else {
    echo json_encode(array('status' => 'gagal', 'message' =>mysqli_error($conect)));
}
}else if ($_SERVER['REQUEST_METHOD'] == 'DELETE') {
    // ambil id dari query parameter
    $id = $_GET['id'];
    
    // hapus data dari database
    $sql = "DELETE FROM catatan_keuangan WHERE id = {$id}";
    $result = mysqli_query($conect, $sql);
    
    if ($result) {
        echo json_encode(array('status' => 'sukses', 'message' => 'Data berhasil dihapus'));
    } else {
        echo json_encode(array('status' => 'gagal', 'message' => mysqli_error($conect)));
    }
}
?>