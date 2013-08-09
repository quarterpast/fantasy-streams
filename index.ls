require! stream.Readable

# Readable.of :: a -> Readable a
Readable.of = (body)->
	new class extends Readable
		offset: 0
		_read: (size)->
			@push body.slice @offset,@offset+size-1
			@offset += size-1
			if @offset > body.length then return @push null # end the Readable
Buffer::concat = (o)-> Buffer.concat [this,o]

Readable::take = (n)->
	orig = this

	new class extends Readable
		->
			super ...
			@consumed = new Buffer ""
			@n = n
		_read: (size)->
			return @push null if @n is 0
			if size < @n
				if (orig.read size)?
					@push that
					@consumed ++= that
					@n -= that.length
				else @push ""
			else
				if (orig.read n)?
					@push that.slice 0 @n
					@consumed ++= that
				@push null
				orig.unshift @consumed

Readable::concat = (b)->
	a = this

	new class extends Readable
		->@read-from = a

		_read: (size)->
			if (@read-from.read size)?
				@push that
			else if @read-from is a
				@read-from = b
				@push ""
			else
				@push null

(Readable.of("hello ") ++ Readable.of("world"))
.pipe process.stdout