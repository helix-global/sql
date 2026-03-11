using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SetIdentityInsertStatement))]
    internal class SqlFragmentSetIdentityInsertStatement : SqlFragmentSetOnOffStatement<SetIdentityInsertStatement>
        {
        #region ctor{IServiceProvider,SetIdentityInsertStatement}
        public SqlFragmentSetIdentityInsertStatement(IServiceProvider context,SetIdentityInsertStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }