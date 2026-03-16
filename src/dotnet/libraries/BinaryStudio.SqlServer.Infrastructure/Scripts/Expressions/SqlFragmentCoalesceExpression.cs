using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(CoalesceExpression))]
    internal sealed class SqlFragmentCoalesceExpression : SqlFragmentPrimaryExpression<CoalesceExpression>
        {
        #region ctor{IServiceProvider,CoalesceExpression}
        public SqlFragmentCoalesceExpression(IServiceProvider context,CoalesceExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }