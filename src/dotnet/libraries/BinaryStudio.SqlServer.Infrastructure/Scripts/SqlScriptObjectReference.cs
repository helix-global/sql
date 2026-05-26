using System;
using JetBrains.Annotations;
using SqlCodeDomObjectReference=Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlObjectReference;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(SqlCodeDomObjectReference))]
    internal sealed class SqlScriptObjectReference : SqlScriptCodeObject<SqlCodeDomObjectReference>
        {
        [UsedImplicitly][Field] public SqlObjectIdentifier ObjectIdentifier { get; }

        #region ctor{IServiceProvider,SqlCodeDomObjectReference}
        public SqlScriptObjectReference(IServiceProvider context,SqlCodeDomObjectReference source)
            : base(context,source)
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