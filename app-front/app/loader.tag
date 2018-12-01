import 'loaders.css/loaders.min.css'

<loader>
	<div class="loader-inner ball-pulse text-center">
		<div/>
		<div/>
		<div/>
	</div>

	<style>
		.ball-pulse > div {
			background-color: gray;
		}
	</style>
</loader>

<loader-circle>
	<div class="loader-inner ball-clip-rotate">
		<div/>
	</div>

	<style>
		.ball-clip-rotate > div {
			border-color: gray;
			border-bottom-color: transparent;
			width: 0.8em;
			height: 0.8em;
		}
	</style>
</loader-circle>
