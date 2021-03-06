///provides target model's filtering and sorting
Object {
	signal reset;				///< emitted when model is reset
	signal rowsInserted;		///< emitted when row is inserted
	signal rowsChanged;			///< emitted when row is changed
	signal rowsRemoved;			///< emitted when row is removed
	property int count;			///< rows count property
    property Object target;		///< target model object

	/// @private
	constructor: {
		this._indexes = []
	}

	///this method set target model rows filter function, 'filter' function must return boolean value, 'true' - when row must be displayed, 'false' otherwise
	function setFilter(filter) {
		this._filter = filter
		this._buildIndexMap()
	}

	///this method set a comparison function, target model rows are sorted in ascending order according to a comparison function 'cmp'
	function setCompare(cmp) {
		this._cmp = cmp
		this._buildIndexMap()
	}

	/// @private
	function _buildIndexMap() {
		this.clear()
		var targetRows = this.target._rows
		if (!targetRows) {
			log("Bad target model")
			return
		}
		if (this._filter) {
			for (var i = 0; i < targetRows.length; ++i)
				if (this._filter(targetRows[i])) {
					var last = this._indexes.length
					this._indexes.push(i)
				}
		} else {
			for (var i = 0; i < targetRows.length; ++i) {
				this._indexes.push(i)
			}
		}
		if (this._cmp) {
			var self = this
			this._indexes = this._indexes.sort(function(a, b) { return self._cmp(targetRows[a], targetRows[b]) })
		}
		this.count = this._indexes.length
		this.rowsInserted(0, this.count)
	}

	///returns a model's row by index, throw exception if index is out of range or if requested row is non-object
	function get(idx) {
		var targetRows = this.target._rows
		if (!targetRows)
			throw new Error('Bad target model')
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		var row = targetRows[this._indexes[idx]]
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		row.index = idx
		return row
	}

	///remove all rows
	function clear() {
		this._indexes = []
		this.count = 0
		this.reset()
	}

	///append row to the model
	function append(row) {
		this.target.append(row)
	}

	///place row at requested index, throws exception when index is out of range
	function insert(idx, row) {
		if (idx < 0 || idx > this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')

		var targetIdx = this._indexes[idx]
		this._rows.splice(targetIdx, 0, row)
		this.target.rowsInserted(targetIdx, targetIdx + 1)
	}

	///replace row at 'idx' position by 'row' argument, throws exception if index is out of range or if 'row' isn't Object
	function set(idx, row) {
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		var targetIdx = this._indexes[idx]
		this.target._rows[targetIdx] = row
		this.target.rowsChanged(targetIdx, targetIdx + 1)
	}

	///replace a row's property, throws exception if index is out of range or if 'row' isn't Object
	function setProperty(idx, name, value) {
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		var targetIdx = this._indexes[idx]
		var row = this.target._rows[targetIdx]
		if (!(row instanceof Object))
			throw new Error('row is non-object, invalid index? (' + idx + ')')

		row[name] = value
		this.target.rowsChanged(targetIdx, targetIdx + 1)
	}

	///remove rows from model from 'idx' to 'idx' + 'n' position
	function remove(idx, n) {
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		this.target.remove(this._indexes[idx], n)
	}

	///this method is alias for 'append' method
	function addChild(child) {
		this.append(child)
	}

	/// @private
	function _onReset() {
		this.clear()
	}

	/// @private
	function _onRowsInserted(begin, end) {
		this._buildIndexMap()
	}

	/// @private
	function _onRowsChanged(begin, end) {
		var targetRows = this.target._rows
		if (!targetRows)
			throw new Error('Bad target model')

		for (var i = begin; i < end; ++i) {
			var idx = this._indexes.indexOf(i)
			if (idx >= 0)
				this.rowsChanged(idx, idx + 1)
		}
	}

	/// @private
	function _onRowsRemoved(begin, end) {
		var targetRows = this.target._rows
		if (!targetRows)
			throw new Error('Bad target model')

		for (var i = begin; i < end; ++i) {
			var idx = this._indexes.indexOf(i)
			if (idx >= 0) {
				this._indexes.splice(idx, 1)
				this.rowsRemoved(idx, idx + 1)
			}
		}
	}

	/// @private
	onCompleted: {
		this.target.on('reset', this._onReset.bind(this))
		this.target.on('rowsInserted', this._onRowsInserted.bind(this))
		this.target.on('rowsChanged', this._onRowsChanged.bind(this))
		this.target.on('rowsRemoved', this._onRowsRemoved.bind(this))

		this._buildIndexMap()
	}
}
