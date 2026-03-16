using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlOffsetFetchClause))]
    internal sealed class SqlScriptOffsetFetchClause : SqlScriptCodeObject<SqlOffsetFetchClause>
        {
        #region ctor{IServiceProvider,SqlOffsetFetchClause}
        public SqlScriptOffsetFetchClause(IServiceProvider context,SqlOffsetFetchClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }