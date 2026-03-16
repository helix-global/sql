using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptConditionClause<T> : SqlScriptCodeObject<T>
        where T : SqlConditionClause
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptConditionClause(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlConditionClause))]
    internal sealed class SqlScriptConditionClause : SqlScriptConditionClause<SqlConditionClause>
        {
        #region ctor{IServiceProvider,SqlConditionClause}
        public SqlScriptConditionClause(IServiceProvider context,SqlConditionClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }