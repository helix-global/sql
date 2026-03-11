using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SetOffsetsStatement))]
    internal class SqlFragmentSetOffsetsStatement : SqlFragmentSetOnOffStatement<SetOffsetsStatement>
        {
        #region ctor{IServiceProvider,SetOffsetsStatement}
        public SqlFragmentSetOffsetsStatement(IServiceProvider context,SetOffsetsStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }