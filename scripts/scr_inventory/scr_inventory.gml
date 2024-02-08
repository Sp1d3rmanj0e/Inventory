
global.current_packet = noone;

function create_inventory(_size) {
	return ds_grid_create(1, _size);
}

function add_item(_inventoryId, _slot, _itemId, _name, _sprite, _quantity, _description) {
	var _itemMap = {
		"id"		: _itemId,
		"name"		: _name,
		"sprite"	: _sprite,
		"quantity"	: _quantity,
		"desc"		: _description
	}
	
	ds_grid_add(_inventoryId, 0, _slot, _itemMap);
}

function draw_inventory(_inventoryId, _startX, _startY, _width, _height, _boxSize, _numRows, _numColumns) {
	
	var _inventorySlotNum = 0;
	
	for (var _column = 0; _column < _numColumns; _column++) {
	for (var _row = 0; _row < _numRows; _row++) {
		
		// Draw a slot in the inventory
		draw_box(_startX + _boxSize * _column, _startY + _boxSize * _row, _boxSize, _inventoryId, _inventorySlotNum);
		
		// Increase this number to tell the box which slot in the inventory it represents
		_inventorySlotNum++;
	}}
	
}

/// @returns A map containing the item's information
// If no grid exists, it will return 0
function inventory_get_item(_inventoryId, _slotNum) {
	
	return ds_grid_get(_inventoryId, 0, _slotNum);
}

// Reset the grid location back to default value
function inventory_remove_item(_inventoryId, _slotNum) {
	ds_grid_set(_inventoryId, 0, _slotNum, 0);
}

function inventory_put_item(_inventoryId, _inventorySlotNum, _packetId) {
	
	// Unpack the packet
	var _itemId		= _itemMap[$ "id"];
	var _itemName	= _itemMap[$ "name"];
	var _itemSprite = _itemMap[$ "sprite"];
	var _itemQty	= _itemMap[$ "quantity"];
	var _itemDesc	= _itemMap[$ "desc"];
	
	add_item(_inventoryId, _inventorySlotNum, _itemId, _itemName, _itemSprite, _itemQty, _itemDesc);
}

function pick_up_item(_inventoryId, _inventorySlotNum, _id, _name, _sprite, _qty, _desc) {
	
	
	// Get the item information from this slot
	var _packetId = instance_create_layer(mouse_x, mouse_y, "Instances", obj_itemPacket,
	{
		parent_inventory_id : _inventoryId,
		parent_inventory_slot : _inventorySlotNum,
		item_id : _id,
		item_name : _name,
		item_sprite : _sprite,
		item_qty : _qty,
		item_desc : _desc
	});
	
	// Remove the item from the inventory
	inventory_remove_item(_inventoryId, _inventorySlotNum);
	
	// Check to see if hand already has an item
	// If so, we will put our current item in this new slot
	if (global.current_packet != noone) {
		inventory_put_item(_inventoryId, _inventorySlotNum, global.current_packet);
	}
	
	global.current_packet = _packetId;
}

function draw_box(_topLeftX, _topLeftY, _boxSize, _inventoryId, _inventorySlotNum) {
	
	var _mouseInBox = mouse_in_box(_topLeftX, _topLeftY, _boxSize);
	
	// Check if mouse is within the box
	if (_mouseInBox)
		draw_set_color(c_yellow);
	else
		draw_set_color(c_white);
		
	// Draw the box
	draw_rectangle(_topLeftX, _topLeftY, _topLeftX + _boxSize-1, _topLeftY + _boxSize-1, true);
	
	// Get the corresponding item based on its inventory slot number
	var _itemMap = inventory_get_item(_inventoryId, _inventorySlotNum);
	
	if (_itemMap == 0) {
		return
	}
	
	var _itemId		= _itemMap[$ "id"];
	var _itemName	= _itemMap[$ "name"];
	var _itemSprite = _itemMap[$ "sprite"];
	var _itemQty	= _itemMap[$ "quantity"];
	var _itemDesc	= _itemMap[$ "desc"];
	
	// Item is clicked
	if (mouse_check_button_pressed(mb_left)) and (_mouseInBox) {
		pick_up_item(_inventoryId, _inventorySlotNum, _itemId, _itemName, _itemSprite, _itemQty, _itemDesc);
	}
	
	
	// Draw the icon (origin is in the top left)
	draw_sprite(_itemSprite, 0, _topLeftX, _topLeftY);
	
	// Draw the box text
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	
	draw_text(_topLeftX + _boxSize/2, _topLeftY + _boxSize, _itemName);
	
	draw_set_halign(fa_right)
	
	draw_text(_topLeftX + _boxSize, _topLeftY + _boxSize, string(_itemQty));
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// Returns if the mouse is in a box's square
function mouse_in_box(_topLeftX, _topLeftY, _boxSize) {
	return point_in_rectangle(
		mouse_x, mouse_y, 
		_topLeftX, _topLeftY,
		_topLeftX + _boxSize, 
		_topLeftY + _boxSize);
}