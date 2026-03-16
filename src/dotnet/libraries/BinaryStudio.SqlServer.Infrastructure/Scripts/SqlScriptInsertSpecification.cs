using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlInsertSpecification))]
    internal sealed class SqlScriptInsertSpecification : SqlScriptDmlSpecification<SqlInsertSpecification>
        {
        #region ctor{IServiceProvider,SqlInsertSpecification}
        public SqlScriptInsertSpecification(IServiceProvider context,SqlInsertSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }