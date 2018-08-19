import route from 'riot-route/lib/tag'

<header>
	<router>
		<route path=""><navbar></route>
		<route path="polls.."><navbar page="polls"></route>
	</router>
</header>

<navbar>
	<nav class="navbar navbar-expand-lg navbar-light bg-light">
		<a class="navbar-brand" href="#">app</a>
		<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarNav">
			<ul class="navbar-nav">
				<li class={nav-item:true, active:opts.page=='polls'}>
					<a class="nav-link" href="#polls">polls</a>
				</li>
			</ul>
		</div>
	</nav>
</navbar>
