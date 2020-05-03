import querystring from 'querystring'
import './loader.tag'
import './octicons.tag'

<author-list>
	<div class="container">
		<form class="mt-2 mb-1" onsubmit={ submit }>
			<div class="input-group">
				<input class="form-control" type="search" name="search" value={ queries.search } oninput={ input } />
				<div class="input-group-append">
					<button class="btn btn-outline-primary dropdown-toggle" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
						{ this.orderings[this.queries.ordering || ''] }
					</button>
					<div class="dropdown-menu">
						<button each={ name, i in orderings } class="dropdown-item btn btn-outline-primary { active: i == (this.queries.ordering||'') }" data-key="ordering" data-value={ i } onclick={ change_query }>{ name }</button>
					</div>
				</div>
			</div>
		</form>

		<div class="d-flex justify-content-between mb-1">
			<div>
				<span if={ !loading } class="text-secondary">{ count.toLocaleString() } authors</span>
			</div>
			<div>
				<button class="btn btn-outline-secondary btn-sm active"><octicons symbol="list-unordered"/></button>
			</div>
		</div>

		<table class="table table-striped">
			<thead>
				<tr>
					<th>Author</th>
					<th>Action</th>
				</tr>
			</thead>
			<tbody>
				<tr each={ items }>
					<td><a href={ '#books?authors__name=' + name }>{ name }</a></td>
					<td><a href="/admin/viewer/book/{ id }/change/" target="_blank" rel="noopener">Admin</a></td>
				</tr>
			</tbody>
		</table>

		<loader if={ loading }/>
		<detector onvisible={ next } margin='500px' />
	</div>

	<script>
		this.orderings = {
			'': 'Default',
			'-pub_date': 'Newest',
			'pub_date': 'Oldest',
			'random': 'Random',
		}
		this.queries = querystring.parse(location.hash.split('?')[1])
		this.loading = true

		this.on('route', () => {
			if (process.env.DEBUG) console.log('route')

			//クエリパラメータを取得
			this.queries = querystring.parse(location.hash.split('?')[1])
			if (process.env.DEBUG) console.log(this.queries)

			fetch('/viewer/authors/?' + querystring.stringify(this.queries))
			.then(data => data.json())
			.then(json => {
				this.items = json.results
				this.count = json.count
				this.next_url = json.next
				this.update({loading: false})
			})
		})

		this.update_location = () => {
			let new_hash = '#authors'
			let new_querystring = querystring.stringify(this.queries)
			if (new_querystring) {
				new_hash = '#authors?' + new_querystring
			}

			if (process.env.DEBUG) {
				console.log(location.hash)
				console.log(new_hash)
			}

			location.hash = new_hash
		}

		this.input = (e) => {
			this.queries.search = e.target.value
		}

		this.submit = (e) => {
			e.preventDefault()
			this.update_location()
		}

		this.change_query = (e) => {
			let value = e.target.dataset.value
			if (value) {
				this.queries[e.target.dataset.key] = value
			}
			else {
				delete this.queries[e.target.dataset.key]
			}
			this.update_location()
		}

		this.next = () => {
			if (!this.loading && this.next_url) {
				this.loading = true
				this.update()
				fetch(this.next_url)
				.then(data => data.json())
				.then(json => {
					this.items = [...this.items, ...json.results]
					this.next_url = json.next
					this.loading = false
					this.update()
				})
			}
		}
	</script>
</author-list>

<detector>
	<script>
		const observer = new IntersectionObserver((entries) => {
			entries.forEach(entry => {
				if (entry.isIntersecting) {
					opts.onvisible()
				}
			})
		}, {
			rootMargin: opts.margin
		})

		this.on('mount', () => observer.observe(this.root))
		this.on('unmount', () => observer.unobserve(this.root))
	</script>
</detector>
