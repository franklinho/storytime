
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("rankingManual", function(request, response) {
  var query = new Parse.Query("Story");
  query.desending("createdAt");
  query.limit(1000);
  query.find({
    success: function(results) {
      for (var i = 0; i < results.length; ++i) {
        var object = results[i];
		var upvotes = object.get("upvotes")
		var downvotes = object.get("downvotes")
		var createdAt = object.createdAt
		var seconds_since_founding =  Math.abs((object.createdAt.getTime()/1000 - 1134028003))
		var s = upvotes - downvotes;
		var order = Math.log(Math.max(Math.abs(s), 1))/ Math.LN10;

		var sign = 0
		if (s > 0) {
		sign = 1
		} else if (s < 0) {
		sign = -1
		}

		var finalRedditValue = (sign * order + seconds_since_founding / 45000)
		object.set("rankingValue", finalRedditValue)
		object.save()

      }
      response.success(results.length + " stories");
    },
    error: function() {
      response.error("story lookup failed");
    }
  });
});

Parse.Cloud.job("rankingAlgo", function(request, response) {
  var query = new Parse.Query("Story");
  query.descending("createdAt");
  query.limit(1000);
  query.find({
    success: function(results) {
      for (var i = 0; i < results.length; ++i) {
        var object = results[i];
		var upvotes = object.get("upvotes")
		var downvotes = object.get("downvotes")
		var createdAt = object.createdAt
		var seconds_since_founding =  Math.abs((object.createdAt.getTime()/1000 - 1134028003))
		var s = upvotes - downvotes;
		var order = Math.log(Math.max(Math.abs(s), 1))/ Math.LN10;

		var sign = 0
		if (s > 0) {
		sign = 1
		} else if (s < 0) {
		sign = -1
		}

		var finalRedditValue = (sign * order + seconds_since_founding / 45000)
		object.set("rankingValue", finalRedditValue)
		object.save()

      }
      response.success(results.length + " stories");
    },
    error: function() {
      response.error("story lookup failed");
    }
  });
});
