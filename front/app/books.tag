import querystring from 'querystring'
import './loader.tag'
import './octicons.tag'

<book-list>
	<div class="container">
		<form class="mt-2 mb-1" onsubmit={ submit }>
			<div class="input-group">
				<div if={ queries.authors__name || queries.title } class="input-group-prepend">
					<button if={ queries.authors__name } class="btn btn-outline-primary" type="button" data-key="authors__name" data-value="" onclick={ change_query }>Author: { queries.authors__name }</button>
					<button if={ queries.title } class="btn btn-outline-primary" type="button" data-key="title" data-value="" onclick={ change_query }>Title: { queries.title }</button>
				</div>
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
		<book-results if={ video_results_is_visible } pagination=true queries={ queries }>
	</div>

	<script>
		this.orderings = {
			'': 'Default',
			'-pub_date': 'Newest',
			'pub_date': 'Oldest',
		}
		this.queries = querystring.parse(location.hash.split('?')[1])

		this.on('route', () => {
			if (process.env.DEBUG) console.log('route')

			//結果をアンマウント
			this.video_results_is_visible = false
			this.update()

			//クエリパラメータを取得
			this.queries = querystring.parse(location.hash.split('?')[1])
			if (process.env.DEBUG) console.log(this.queries)

			//結果をマウント
			this.video_results_is_visible = true
			this.update()
		})

		this.update_location = () => {
			let new_hash = '#books'
			let new_querystring = querystring.stringify(this.queries)
			if (new_querystring) {
				new_hash = '#books?' + new_querystring
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
	</script>
</book-list>

<book-results>
	<div if={ opts.pagination } class="d-flex justify-content-between mb-1">
		<div>
			<span if={ !loading } class="text-secondary">{ count.toLocaleString() } books</span>
		</div>
		<div>
			<button class="btn btn-outline-secondary btn-sm { active: mode=='card' }" onclick={ () => { this.mode='card'; this.update();} } ><octicons symbol="note"/></button>
			<button class="btn btn-outline-secondary btn-sm { active: mode=='table' }" onclick={ () => { this.mode='table'; this.update();} } ><octicons symbol="list-unordered"/></button>
		</div>
	</div>

	<div if={mode == 'card' } class="row">
		<div class="col-12 col-sm-6 col-lg-4" each={ items } onclick={ showdetail }>
			<div class="card mb-3">
				<thumbnail images={ pages }/>
				<div class="card-body">
					<a class="card-link" href="#pages/{ id }" target="_blank" rel="noopener">{ title } { volume }</a>
					<div class="d-flex justify-content-between flex-wrap">
						<div class="d-flex">
							<div class="pr-2" each={ author in authors }><small><a class="text-muted" href="#books?authors__name={ author.name }">{ author.name }</a></small></div>
						</div>
						<div class="pr-2">
							<small><a class="text-muted" href="#books?title={ title }">{ title }</a></small>
						</div>
						<div if={ pub_date }>
							<small><span class="text-muted">{ pub_date }</span></small>
						</div>
						<div class="ml-auto">
							<small><a class="text-muted" href="/admin/viewer/book/{ id }/change/" target="_blank" rel="noopener">Admin</a></small>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<table if={ mode == 'table' } class="table table-striped">
		<thead>
			<tr>
				<th>Title</th>
				<th>Volume</th>
				<th>Authors</th>
				<th>Action</th>
			</tr>
		</thead>
		<tbody>
			<tr each={ items } onclick={ showdetail }>
				<td><a href={ '#books?title=' + title }>{ title }</a></td>
				<td>{ volume }</td>
				<td><span class="mr-1" each={ author in authors }><a href={ '#books?authors__name=' + author.name }>{ author.name }</a></span></td>
				<td><a href="#pages/{ id }" target="_blank" rel="noopener">Open</a></td>
			</tr>
		</tbody>
	</table>

	<loader if={ loading }/>
	<detector if={ opts.pagination } onvisible={ next } margin='500px' />

	<script>
		this.loading = true
		this.mode = 'card'

		this.on('mount', () => {
			fetch('/viewer/books/?' + querystring.stringify(opts.queries))
			.then(data => data.json())
			.then(json => {
				this.update({
					items: json.results,
					count: json.count,
					next_url: json.next,
					loading: false,
				})
			})
		})

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
</book-results>

<thumbnail>
	<div class="card-img-top embed-responsive embed-responsive-4by3 bg-light" onmouseover={ mouseover } onmouseout={ mouseout }>
		<object each={ image, i in opts.images } if={ i == index } data={ image } style="object-fit: contain"/>
		<!-- Cache -->
		<object each={ image, i in opts.images } if={ i == index+1 } data={ image } show={ false } style="object-fit: contain"/>
	</div>

	<script>
		this.index = 0

		this.mouseover = (e) => {
			if (process.env.DEBUG) console.log('mouseover')
			this.timer = setInterval(() => {
				this.index = (this.index+1)%opts.images.length
				this.update()
			}, 1000)
		}

		this.mouseout = (e) => {
			if (process.env.DEBUG) console.log('mouseout')
			clearInterval(this.timer)
		}
	</script>
</thumbnail>

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
