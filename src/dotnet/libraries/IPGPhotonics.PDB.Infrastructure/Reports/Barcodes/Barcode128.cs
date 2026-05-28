using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal class Barcode128 : LinearBarcodeBase
        {
        [UsedImplicitly][Field] public Boolean AutoEncode { get; } = true;
        }
    }