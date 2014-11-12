{if condition="html"}
	<!DOCTYPE html>
	<html lang="en">
	<head>
		{include file="master2/head.tpl"/}
	</head>
	<body>
{/if}

{unless condition="$web"}	
		<!-- Site Navigation -->
	{include file="master2/site_navigation.tpl"/}	
{/unless}

{if condition="html"}

<div class="container">
		<hr>
		<div class="row">
			<main class="main">
{/if}


<div class="container-fluid">
	<div class="col-xs-12" itemscope itemtype="http://schema.org/Article">
		<form class="form-inline well"  action="{$host/}/node/{$id/}/content" method="POST" class="">
			<input type="hidden" name="method" value="PUT">	
			<fieldset>
				<legend>Edit Node Content</legend>

					<div class="row">
						<div class="col-xs-1">
							<label> <span itemprop="text">Content:</span>   </label>
						</div>
						<div class="col-xs-7">
					        	<textarea id="content" rows="25" cols="100" class="form-control" name="content" placeholder="Node content" required>{$node_content/}</textarea>			
					   	</div>
					</div>

			   <div>
				    <label>
				        <span>&nbsp;</span> 
				        <input type="Submit" value="Update" /> 
				    </label>
				</div>    
			</fieldset>      
		</form> 
	</div>
</div>
{if condition="html"}

			</main>
		</div>
	</div>
{/if}


{if condition="html"}
	<div id="footer">
			<footer class="site-footer">
				{include file="master2/footer.tpl"/}			
			</footer>
		</div>


			{include file="master2/optional_enhancement_js.tpl"/}
		
	</body>
	</html>
{/if}	             			              