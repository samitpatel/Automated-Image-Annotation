<?php

class UploadData extends CI_Controller{
	

	function index(){
		$this->load->helper('file');
	
		$fileData = read_file('files/Image_Region_Label.txt');
		///[\s,]+/
		$data = preg_split("[\r\n]", $fileData);
		
		//var_dump($data);
		
		$data_batch = array();
		$classes = array();
		
		for($i=0; $i < sizeof($data); $i++){
			
			//print_r($data[$i]."\n");
			$d = preg_split("/[\s,]+/", $data[$i]);
			if(sizeof($d) < 3){
				continue;
			}
			$image = $d[0];
			$region = $d[1];
			$class = $d[2];
			
			//print_r($image."->".$region."->".$class."\n");
			
			if(empty($image) || empty($region) || empty($class)){
				continue;
			}
			
			$in = array(
				'image' => $image,
				'class'	=> $class
			);
			
			//if($this->db->get_where('imageClasses', $in)->num_rows() == 0){
				$this->db->insert('imageClasses', $in);
			//}
			
			if(!in_array($class, $classes)){
				$c = array(
						'id' => $class
					);
				array_push($classes, $class);
				$this->db->insert('classes', $c);
			}
			
				
			//array_push($data_batch, $in);
			
		}
		
		
		//$this->db->insert_batch('classes', $classes);	
	}
}

?>