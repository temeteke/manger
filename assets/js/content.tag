import './home.tag'
import './viewer.tag'

<content>
	<router>
		<route path=""><home/></route>
		<route path="viewer/.."><page-list/></route>
		<route path="viewer.."><book-list/></route>
	</router>
</content>
