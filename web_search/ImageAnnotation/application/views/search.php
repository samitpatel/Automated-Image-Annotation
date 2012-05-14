<html>
<?php

	$images = array();
	$q = "";
	$t = 1;
	
	if($this->input->get('q')){
		
		$q = $this->input->get('q');
		if($this->input->get('t')){
			$t = $this->input->get('t');
		}
		
		$this->db->select('image, count(class) as c');
		$this->db->from('imageClasses');
		$this->db->join('classes', 'classes.id = imageClasses.class');
		$this->db->where(array('name' => $q, 'isTest' => $t));
		$this->db->group_by('image');
		$this->db->order_by('c', 'desc');
		$this->db->limit(60);
		
		$query = $this->db->get();
		
		foreach($query->result() as $row){
			$images[] = $row->image;	
		}
		
	}
?>
<body>
<center>
<br/>
<div style="font-size:20pt; text-align=center">
	Segment-Based Image Retrieval
</div>
<br/>

<form method = "get" action="search" id="search-form">
	<div style="margin-left:38%">
		<div style="float:left;">
			<input style="font-size:13pt; border-color:#EDE6E9; -webkit-border-radius: 3px; height:25pt; width:200" type="text" name = "q" value="<?php echo $q; ?>" id = "q" />
			<!--<select name='t' style="height:25pt">
				<option <?php if($t == 1){ echo "selected"; }?> value="1">Test</option>
				<option <?php if($t == 0){ echo "selected"; }?> name="0" value="0">Training</option>
			</select>-->
			<!--<input type="submit" value="Search" />-->
		</div>
		<div id = "search" style="margin-left:1%; float:left; padding-top:6px; mouse:pointer; border-color:#000000; width:100; height:25; -webkit-border-radius: 3px; background:#F0F0F0">
			<span style="color:#4D4D4D">Search</span>
		</div>
	</div>
</form>
</center>
<br/><br/>

<div style="padding-left:23px">

<!--<img src="<?php echo base_url(); ?>ImageAnnotation/images/00/images/668.jpg" height=150 width=200 />-->

<?php foreach($images as $image) {
	
		if(strlen($image) <= 3){
			$folder = "00";
		}else{
			$folder = substr($image, 0, strlen($image)-3);
			if(strlen($folder) < 2){
				$folder = "0".$folder;
			}
		}
		$href = base_url()."images/".$folder."/images/".$image.".jpg";
	?>
	<a href="<?php echo $href; ?>" target="new"><img src="<?php echo $href; ?>" height=150 width=200 /></a>
<?php } ?>
</div>
</body>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
<script>
$("#search").click(function(){
	$("#search-form").submit();
})
</script>
</html>