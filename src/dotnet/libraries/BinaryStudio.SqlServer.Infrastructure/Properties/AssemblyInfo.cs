using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Windows.Markup;

[assembly: Guid("1d40b83d-2665-401e-a1ca-cf1e800ca3f4")]
[assembly: InternalsVisibleTo("IPGPhotonics.PDB.Infrastructure")]
#if UseWPF
[assembly: XmlnsPrefix("http://schemas.helix.global", "u")]
[assembly: XmlnsDefinition("http://schemas.helix.global", "BinaryStudio.DataProcessing")]
#endif
