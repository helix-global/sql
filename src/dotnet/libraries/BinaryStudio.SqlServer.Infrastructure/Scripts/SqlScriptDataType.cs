using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    using DataType=Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlDataType;

    [SqlScriptObject(typeof(DataType))]
    internal sealed class SqlScriptDataType : SqlScriptCodeObject<DataType>,ISqlScriptDataType
        {
        [UsedImplicitly][Field] public Boolean National { get; }
        [UsedImplicitly][Field] public Boolean Varying { get; }
        [UsedImplicitly][Field] public SqlObjectIdentifier ObjectIdentifier { get; }

        #region ctor{IServiceProvider,SqlDataType}
        public SqlScriptDataType(IServiceProvider context,DataType source)
            : base(context, source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return ObjectIdentifier.ToString();
            }
        #endregion
        }
    }