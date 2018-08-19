<polls>
	<div each={ items }>
		<span>{ id }</span>
		<span>{ question_text }</span>
		<span>{ pub_date }</span>
	</div>

	<script>
		fetch('/polls/questions')
		.then(data => data.json())
		.then(json => {
			this.items = json.results
			this.update()
		})
	</script>
</polls>
