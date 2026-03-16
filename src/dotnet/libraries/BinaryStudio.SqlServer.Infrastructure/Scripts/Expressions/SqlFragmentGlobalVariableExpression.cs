using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(GlobalVariableExpression))]
    internal sealed class SqlFragmentGlobalVariableExpression : SqlFragmentValueExpression<GlobalVariableExpression>
        {
        #region ctor{IServiceProvider,GlobalVariableExpression}
        public SqlFragmentGlobalVariableExpression(IServiceProvider context,GlobalVariableExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }