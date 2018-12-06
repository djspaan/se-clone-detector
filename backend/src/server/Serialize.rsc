module server::Serialize

import clonedet::Clonedet;



value serialize(duplicate(int \type, int weight, set[loc] locs)) 
	= ("type": \type, "weight": weight, "locs": locs);

value serialize(value v) = "<v>";