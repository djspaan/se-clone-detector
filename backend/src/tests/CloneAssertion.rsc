module tests::CloneAssertion

data CloneAssertion = atMostInRange(int cloneType, loc location, int count)
				    | atLeastInRange(int cloneType, loc location, int count)
				    | atLeastInRange(int cloneType, loc location, int count, int minWeight);
