using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(MoneyLiteral))]
    internal sealed class SqlFragmentMoneyLiteral : SqlFragmentLiteral<MoneyLiteral>
        {
        #region ctor{IServiceProvider,MoneyLiteral}
        public SqlFragmentMoneyLiteral(IServiceProvider context,MoneyLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }