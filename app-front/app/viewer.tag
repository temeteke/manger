import querystring from 'querystring'
import $ from 'jquery'
import Cookies from 'js-cookie'
import './loader.tag'

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
	<div class="card mb-3">
		<div class="card-img-top embed-responsive embed-responsive-4by3 bg-light">
			<object data={ opts.data.pages[0] } style="object-fit: contain"/>
		</div>
		<div class="card-body p-4">
			<div class="row">
				<div class="col-12 px-1">
					<a class="card-link" href="#viewer/{ opts.data.id }" target="_blank" rel="noopener">{ opts.data.title } { opts.data.volume }</a>
				</div>
				<div class="col-auto px-1 d-flex">
					<div class="pr-1" each={ author in opts.data.authors }><small><a class="text-muted" href="#viewer?authors__name={ author.name }">{ author.name }</a></small></div>
				</div>
				<div class="col-auto px-1">
					<small><a class="text-muted" href="#viewer?title={ opts.data.title }">{ opts.data.title }</a></small>
				</div>
				<div class="col-auto px-1" if={ opts.data.pub_date }>
					<small><span class="text-muted">{ opts.data.pub_date }</span></small>
				</div>
				<div class="col-auto px-1 ml-auto">
					<small><a class="text-muted" href="/admin/viewer/book/{ opts.data.id }/change/" target="_blank" rel="noopener">管理</a></small>
				</div>
			</div>
		</div>
	</div>
</book-result>

<page-list>
	<div style="display: flex; flex-direction: row-reverse; justify-content: center; align-items: center; background-color: lightgray; height: { height }px;" onclick={ click }>
		<img each={ page_url, i in pages } ref="img" src={ page_url } if={ i >= page && i < page+shown_pages } onload={ resize } style="max-width: 100%; max-height: 100%;"/>
	</div>

	<script>
		this.book_id = Number(location.hash.split('/')[1])
		this.page = location.hash.split('/')[2] ? Number(location.hash.split('/')[2]) : 0

		this.shown_pages = 1

		this.on('route', () => {
			if (process.env.DEBUG) console.log('route')
			this.book_id = Number(location.hash.split('/')[1])
			let page = location.hash.split('/')[2]
			if (page) {
				this.page = Number(page)
			}
			else {
				this.get_pages()
			}
		})

		this.on('mount', () => {
			if (process.env.DEBUG) console.log('mount')
			this.get_pages()
		})

		this.get_pages = () => {
			fetch('/viewer/books/' + this.book_id + '/')
			.then(data => data.json())
			.then(json => {
				this.pages = json.pages
				this.page = json.bookmark
				this.update_location()
				this.update()
			})
		}

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

		this.click = (e) => {
			if (e.clientX < window.innerWidth/2) {
				this.go_to(this.page+this.shown_pages)
			}
			else {
				this.go_to(this.page-this.shown_pages)
			}
		}

		this.keydown = (e) => {
			switch (e.key) {
				case 'ArrowRight':
					this.go_to(this.page-this.shown_pages)
					break
				case 'ArrowLeft':
					this.go_to(this.page+this.shown_pages)
					break
				case 'ArrowUp':
					this.go_to(this.page-1)
					break
				case 'ArrowDown':
					this.go_to(this.page+1)
					break
				case 'PageUp':
					this.go_to(this.page-10)
					break
				case 'PageDown':
					this.go_to(this.page+10)
					break
				case 'Home':
					this.go_to(0)
					break
				case 'End':
					this.go_to(this.pages.length-1)
					break
			}
		}

		this.go_to = (page) => {
			if (page < 0) {
				page = 0
			}
			else if (page >= this.pages.length) {
				page = this.pages.length-1
			}
			this.page = page
			this.update_location()
			this.update_bookmark()
		}

		this.update_location = () => {
			location.hash = '#viewer/' + this.book_id + '/' + this.page
		}

		this.update_bookmark = () => {
			fetch('/viewer/books/' + this.book_id + '/', {
				method: 'PATCH',
				body: JSON.stringify({bookmark: this.page}),
				headers: {
					'Accept': 'application/json',
					'Content-Type': 'application/json',
					'X-CSRFToken': Cookies.get("csrftoken"),
				},
			})
		}

		window.onresize = this.resize
		document.onkeydown = this.keydown

	</script>
</page-list>

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
