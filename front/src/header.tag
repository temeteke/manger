import route from 'riot-route/lib/tag'
import './octicons.tag'

<header>
	<router>
		<route path=""><navbar></route>
		<route path="viewer/.."></route>
		<route path="books.."><navbar page="books"></route>
		<route path="authors.."><navbar page="authors"></route>
	</router>
</header>

<navbar>
	<nav class="navbar navbar-expand-lg navbar-light bg-light">
		<a class="navbar-brand" href="#">manger</a>
		<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarNav">
			<ul class="navbar-nav">
				<li class={nav-item:true, active:opts.page=='books'}>
					<a class="nav-link" href="#books"><octicons symbol="book" class="p-1"/>Books</a>
				</li>
				<li class={nav-item:true, active:opts.page=='authors'}>
					<a class="nav-link" href="#authors"><octicons symbol="organization" class="p-1"/>Authors</a>
				</li>
				<li>
					<a class="nav-link" href="/admin/" target="_blank" rel="noopener"><octicons symbol="gear" class="p-1"/>Admin</a>
				</li>
			</ul>
		</div>
	</nav>
</navbar>
