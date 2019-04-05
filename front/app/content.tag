import './home.tag'
import './books.tag'
import './authors.tag'
import './pages.tag'

<content>
	<router>
		<route path=""><home/></route>
		<route path="books.."><book-list/></route>
		<route path="authors.."><author-list/></route>
		<route path="pages.."><page-list/></route>
	</router>
</content>
