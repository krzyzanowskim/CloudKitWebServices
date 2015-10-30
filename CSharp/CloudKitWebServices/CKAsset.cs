using System;

namespace CloudKitWebServices
{
	public struct CKAsset
	{
		public Uri fileURI;

		public CKAsset()
		{
			throw new NotSupportedException();
		}

		public CKAsset(Uri fileURI)
		{
			this.fileURI = fileURI;
		}

	}
}

