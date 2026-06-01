using System;
using System.Windows.Forms;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class ComponentBase : Base
        {
        [UsedImplicitly][Field] public Single Left { get; }
        [UsedImplicitly][Field] public Single Top { get; }
        [UsedImplicitly][Field] public Single Width { get; }
        [UsedImplicitly][Field] public Single Height { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<AnchorStyles>))] public AnchorStyles Anchor { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DockStyle>))] public DockStyle Dock { get; }
        [UsedImplicitly][Field] public Boolean Visible { get; } = true;
        }
    }
