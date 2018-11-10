import querystring from 'querystring'
import $ from 'jquery'

<title-list>
	<div class="container">
		<form onsubmit={ submit }>
			<div class="input-group mt-3">
				<input class="form-control" type="search" name="search" value={ queries.search } oninput={ input } />
			</div>
		</form>
		<title-results if={ video_results_is_visible } pagination=true queries={ queries }>
	</div>

	<script>
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
			let new_hash = '#viewer'
			let new_querystring = querystring.stringify(this.queries)
			if (new_querystring) {
				new_hash = '#viewer?' + new_querystring
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
</title-list>

<title-results>
	<div if={ opts.pagination && !loading } class="text-right">{ count }件</div>
	<div class="row">
		<div class="col-12 col-sm-6 col-lg-4" each={ item in items }>
			<title-result data={ item } />
		</div>
	</div>
	<loader if={ loading }/>
	<detector if={ opts.pagination } onvisible={ next } margin='500px' />

	<script>
		this.loading = true

		this.on('mount', () => {
			fetch('/viewer/titles/?' + querystring.stringify(opts.queries))
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
</title-results>

<title-result>
	<div class="card mb-3" onclick={ showdetail }>
		<div class="embed-responsive embed-responsive-16by9 bg-light">
			<object data={ opts.data.package } style="object-fit: contain"/>
		</div>
		<div class="card-body">
			<p class="card-title text-truncate mb-0">{ opts.data.name }</p>
			<p class="card-title">
				<small class="text-muted" each={ author in opts.data.authors }>{ author }</small>
			</p>
		</div>
	</div>

	<script>
		this.showdetail = () => {
			location.hash = '#viewer/' + opts.data.id
		}
	</script>
</title-result>

<volume-list>
	<div class="container">
		<div>タイトル</div>
		<div>作者</div>
		<volume-results if={ volume_results_is_visible } pagination=true queries={ queries } />
	</div>

	<script>
		this.queries = 'title=' + location.hash.split('/')[1]

		this.on('route', () => {
			if (process.env.DEBUG) console.log('route')

			//結果をアンマウント
			this.volume_results_is_visible = false
			this.update()

			//クエリパラメータを取得
			this.queries = 'title=' + location.hash.split('/')[1]
			if (process.env.DEBUG) console.log(this.queries)

			//結果をマウント
			this.volume_results_is_visible = true
			this.update()
		})
	</script>
</volume-list>

<volume-results>
	<div if={ opts.pagination && !loading } class="text-right">{ count }件</div>
	<div class="row">
		<div class="col-12 col-sm-6 col-lg-4" each={ item in items }>
			<volume-result data={ item } />
		</div>
	</div>
	<loader if={ loading }/>
	<detector if={ opts.pagination } onvisible={ next } margin='500px' />

	<script>
		this.loading = true

		this.on('mount', () => {
			fetch('/viewer/volumes/?' + querystring.stringify(opts.queries))
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
</volume-results>

<volume-result>
	<div class="card mb-3" onclick={ showdetail }>
		<div class="embed-responsive embed-responsive-16by9 bg-light">
			<object data={ opts.data.pages[0] } style="object-fit: contain"/>
		</div>
		<div class="card-body">
			<p class="card-title text-truncate mb-0">{ opts.data.number }</p>
		</div>
	</div>

	<title-detail if={ detail_window_is_visible }/>

	<script>
		this.showdetail = () => {
			location.hash = '#viewer/' + opts.data.title + '/' + opts.data.number
		}
	</script>
</volume-result>

<page-list>
	<page-results if={ page_results_is_visible } volume_id={ volume_id } />

	<script>
		this.volume_id = location.hash.split('/')[2]

		this.on('route', () => {
			if (process.env.DEBUG) console.log('route')

			//結果をアンマウント
			this.page_results_is_visible = false
			this.update()

			//クエリパラメータを取得
			this.volume_id = location.hash.split('/')[2]

			//結果をマウント
			this.page_results_is_visible = true
			this.update()
		})
	</script>
</page-list>

<page-results>
	<div class="text-center">
		<button class="btn btn-outline-primary" onclick={ next }>←</button>
		<img src={ page_left } style="height: { height }px;"/>
		<img src={ page_right } style="height: { height }px;"/>
		<button class="btn btn-outline-primary" onclick={ prev }>→</button>
	</div>

	<script>
		this.page = 0

		this.on('mount', () => {
			fetch('/viewer/volumes/' + opts.volume_id)
			.then(data => data.json())
			.then(json => {
				this.pages = json.pages
				this.page_update()
				this.resize()
				this.update()
			})
		})

		this.next = () => {
			if (this.page+2 <= this.pages.length) {
				this.page += 2
				this.page_update()
			}
		}

		this.prev = () => {
			if (this.page-2 >= 0) {
				this.page -= 2
				this.page_update()
			}
		}

		this.page_update = () => {
			this.page_right = this.pages[this.page]
			this.page_left = this.pages[this.page+1]
		}

		this.resize = () => {
			this.height = window.innerHeight - this.root.getBoundingClientRect().top
			this.update()
		}

		window.onresize = () => {
			this.resize()
		}
	</script>
</page-results>
