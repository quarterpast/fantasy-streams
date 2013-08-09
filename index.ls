require! stream.Readable

# monoid
Readable.empty = -> Readable.of ""

# semigroup
Readable::concat = (b)->
	a = this

	new class extends Readable
		->
			super ...
			@read-from = a

		_read: (size)->
			if (@read-from.read size)?
				@push that
			else if @read-from is a
				@read-from = b
				@push ""
			else
				@push null

# chain
Readable::chain = (f)->
	orig = this

	new class extends Readable
		_read: (size)->
			if (orig.read size)?
				if ((f that)read size)?
					@push that
				else @push ""
			else
				@push null

# applicative
Readable.of = (body)->
	new class extends Readable
		offset: 0
		_read: (size)->
			@push body.slice @offset,@offset+size-1
			@offset += size-1
			if @offset > body.length then return @push null # end the Readable

# applicative derived from monad
Readable::ap = (m)->
	@chain (f)->
		m.map f

# functor derived from monad
Readable::map = (f)->
	@chain (a)~>
		Readable.of f a
