using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptSetClause<T> : SqlScriptCodeObject<T>
        where T : SqlSetClause
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptSetClause(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlSetClause))]
    internal sealed class SqlScriptSetClause : SqlScriptCodeObject<SqlSetClause>
        {
        #region ctor{IServiceProvider,SqlSetClause}
        public SqlScriptSetClause(IServiceProvider context,SqlSetClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }