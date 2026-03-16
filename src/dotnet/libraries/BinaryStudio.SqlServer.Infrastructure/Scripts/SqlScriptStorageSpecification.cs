using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlStorageSpecification))]
    internal sealed class SqlScriptStorageSpecification : SqlScriptCodeObject<SqlStorageSpecification>
        {
        #region ctor{IServiceProvider,SqlStorageSpecification}
        public SqlScriptStorageSpecification(IServiceProvider context,SqlStorageSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }