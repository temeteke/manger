import querystring from 'querystring'
import $ from 'jquery'

<book-list>
	<div class="container">
		<form onsubmit={ submit }>
			<div class="input-group mt-3">
				<input class="form-control" type="search" name="search" value={ queries.search } oninput={ input } />
			</div>
		</form>
		<book-results if={ video_results_is_visible } pagination=true queries={ queries }>
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
</book-list>

<book-results>
	<div if={ opts.pagination && !loading } class="text-right">{ count }件</div>
	<div class="row">
		<div class="col-12 col-sm-6 col-lg-4" each={ item in items }>
			<book-result data={ item } />
		</div>
	</div>
	<loader if={ loading }/>
	<detector if={ opts.pagination } onvisible={ next } margin='500px' />

	<script>
		this.loading = true

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

<book-result>
	<div class="card mb-3" onclick={ showdetail }>
		<div class="embed-responsive embed-responsive-4by3 bg-light">
			<object data={ opts.data.pages[0] } style="object-fit: contain"/>
		</div>
		<div class="card-body">
			<p class="card-title text-truncate mb-0">{ opts.data.title } { opts.data.volume }</p>
			<p class="card-title">
				<small class="text-muted" each={ author in opts.data.authors }>{ author }</small>
				<small class="text-muted">{ opts.data.pub_date }</small>
			</p>
		</div>
	</div>

	<script>
		this.showdetail = () => {
			location.hash = '#viewer/' + opts.data.id
		}
	</script>
</book-result>

<page-list>
	<div class="text-center" style="direction: rtl" onclick={ move_page } >
		<img each={ page_url, i in pages } ref="img" src={ page_url } if={ i >= page && i < page+shown_pages } onload={ resize } style="height: { height }px;"/>
	</div>

	<script>
		this.book_id = Number(location.hash.split('/')[1])
		this.page = location.hash.split('/')[2] ? Number(location.hash.split('/')[2]) : 0

		this.shown_pages = 1

		this.on('route', () => {
			console.log('route')
			this.book_id = Number(location.hash.split('/')[1])
			this.page = location.hash.split('/')[2] ? Number(location.hash.split('/')[2]) : 0
			this.update_location()
		})

		this.on('mount', () => {
			fetch('/viewer/books/' + this.book_id + '/')
			.then(data => data.json())
			.then(json => {
				this.pages = json.pages
				this.update()
			})
		})

		this.resize = () => {
			//画像サイズを画面いっぱいにする
			this.height = window.innerHeight - this.root.getBoundingClientRect().top

			//見開き表示の判定
			let imgs = this.refs.img
			if (!Array.isArray(imgs)) {
				imgs = [imgs]
			}

			if (window.innerWidth > window.innerHeight && imgs.every(img => img.width < img.height)) {
				this.shown_pages = 2
			}
			else {
				this.shown_pages = 1
			}

			if (process.env.DEBUG) console.log('shown_pages: ' + this.shown_pages)

			this.update()
		}

		this.move_page = (e) => {
			if (e.clientX < window.innerWidth/2) {
				this.next()
			}
			else {
				this.prev()
			}
		}

		this.next = () => {
			if (this.page+this.shown_pages <= this.pages.length) {
				this.page += this.shown_pages
			}
			else {
				this.page = this.pages.length
			}
			this.update_location()
		}

		this.prev = () => {
			if (this.page-this.shown_pages >= 0) {
				this.page -= this.shown_pages
			}
			else {
				this.page = 0
			}
			this.update_location()
		}

		this.update_location = () => {
			location.hash = '#viewer/' + this.book_id + '/' + this.page
		}

		window.onresize = () => {
			this.resize()
		}
	</script>
</page-list>
