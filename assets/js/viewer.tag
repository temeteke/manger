<viewer>
	<div each={ items }>
		<span>{ id }</span>
		<span>{ title }</span>
		<span>{ pub_date }</span>
	</div>

	<script>
		fetch('/viewer/volumes')
		.then(data => data.json())
		.then(json => {
			this.items = json.results
			this.update()
		})
	</script>
</viewer>
