using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(AtTimeZoneCall))]
    internal sealed class SqlFragmentAtTimeZoneCall : SqlFragmentPrimaryExpression<AtTimeZoneCall>
        {
        #region ctor{IServiceProvider,AtTimeZoneCall}
        public SqlFragmentAtTimeZoneCall(IServiceProvider context,AtTimeZoneCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }