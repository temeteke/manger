import Cookies from 'js-cookie'

<page-list>
	<div style="display: flex; flex-direction: row-reverse; justify-content: center; align-items: center; background-color: lightgray; height: { height }px;" onclick={ click }>
		<!-- Cache -->
		<img each={ page_url, i in pages } ref="img" src={ page_url } if={ i >= page-cache_pages && i < page } show={ false }/>
		<!-- Shown Page -->
		<img each={ page_url, i in pages } ref="img" src={ page_url } if={ i >= page && i < page+shown_pages } onload={ resize } style="max-width: 100%; max-height: 100%;"/>
		<!-- Cache -->
		<img each={ page_url, i in pages } ref="img" src={ page_url } if={ i >= page+shown_pages && i < page+shown_pages+cache_pages } show={ false }/>
	</div>

	<script>
		this.book_id = Number(location.hash.split('/')[1])
		this.page = location.hash.split('/')[2] ? Number(location.hash.split('/')[2]) : 0

		this.shown_pages = 1
		this.cache_pages = 4

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
			if (process.env.DEBUG) console.log('resize')
			//画像サイズを画面いっぱいにする
			this.height = window.innerHeight - this.root.getBoundingClientRect().top

			//見開き表示の判定
			let imgs = this.refs.img
			imgs = imgs.filter( img => !img.hidden )
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
			location.hash = '#pages/' + this.book_id + '/' + this.page
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
