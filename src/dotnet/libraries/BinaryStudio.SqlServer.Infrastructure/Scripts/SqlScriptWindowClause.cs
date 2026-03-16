using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlWindowClause))]
    internal sealed class SqlScriptWindowClause : SqlScriptCodeObject<SqlWindowClause>
        {
        #region ctor{IServiceProvider,SqlWindowClause}
        public SqlScriptWindowClause(IServiceProvider context,SqlWindowClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }